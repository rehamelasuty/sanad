import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/repositories/market_feed_repository.dart';
import '../models/market_tick_model.dart';
import '../workers/tick_parser_worker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketWebSocketDatasource
//
// Responsibilities
// ────────────────
// 1. Manage the WebSocket lifecycle (connect / reconnect / disconnect).
// 2. Route raw WebSocket messages to the background parser Isolate.
// 3. Buffer parsed ticks in a Map<symbol, tick> and flush on a timer.
//
// Why the Map buffer?
// ───────────────────
// The server sends 300-tick batches every 100 ms.  If processing lag
// causes two batches to arrive before the flush timer fires, we don't
// accumulate thousands of ticks — we just keep the *latest* value per
// symbol (Map key = symbol).  The UI always shows the freshest price.
//
// Why the flush timer (not immediate emit)?
// ─────────────────────────────────────────
// Emitting on every parse result would cap UI updates at the server's
// broadcast rate (10 Hz) but makes the cubit rebuild the state map more
// often than necessary.  The timer lets us batch *multiple* server
// messages into a single state update if they arrive close together.
//
// Reconnect strategy — truncated exponential back-off:
//   attempt 1 →  2 s
//   attempt 2 →  4 s
//   attempt 3 →  8 s
//   attempt 4 → 16 s
//   attempt 5 → 30 s  (then give up → FeedConnectionStatus.failed)
// ─────────────────────────────────────────────────────────────────────────────

const _kFlushInterval     = Duration(milliseconds: 100);
const _kReconnectDelays   = [2, 4, 8, 16, 30]; // seconds

class MarketWebSocketDatasource {
  MarketWebSocketDatasource({TickParserWorker? parserWorker})
      : _parser = parserWorker ?? TickParserWorker();

  final TickParserWorker _parser;

  // ── Internals ─────────────────────────────────────────────────────────────
  WebSocketChannel?      _channel;
  StreamSubscription?    _wsSubscription;
  StreamSubscription?    _parserSubscription;
  Timer?                 _flushTimer;
  Timer?                 _reconnectTimer;

  String?  _lastUrl;
  int      _reconnectAttempts = 0;

  /// Accumulates latest tick per symbol between flush windows.
  final Map<String, Map<String, dynamic>> _buffer = {};

  // ── Output streams ────────────────────────────────────────────────────────
  final _tickCtrl   = StreamController<List<MarketTickModel>>.broadcast();
  final _statusCtrl = StreamController<FeedConnectionStatus>.broadcast();

  Stream<List<MarketTickModel>>    get tickStream   => _tickCtrl.stream;
  Stream<FeedConnectionStatus>     get statusStream => _statusCtrl.stream;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Opens the WebSocket and starts the parser isolate.
  /// Throws [Exception] if the connection cannot be established so callers
  /// can convert it to the appropriate [Failure].
  Future<void> connect(String wsUrl) async {
    _lastUrl = wsUrl;
    _reconnectAttempts = 0;
    await _connect(wsUrl);
  }

  /// Sends a clean close frame and releases all resources.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _flushTimer?.cancel();
    await _wsSubscription?.cancel();
    await _parserSubscription?.cancel();
    await _channel?.sink.close();
    await _parser.dispose();
    if (!_statusCtrl.isClosed) {
      _statusCtrl.add(FeedConnectionStatus.disconnected);
    }
  }

  // ── Internal connection flow ──────────────────────────────────────────────

  Future<void> _connect(String wsUrl) async {
    _statusCtrl.add(
      _reconnectAttempts == 0
          ? FeedConnectionStatus.connecting
          : FeedConnectionStatus.reconnecting,
    );

    // ① Ensure the parser isolate is ready.
    if (_reconnectAttempts == 0) await _parser.init();

    // ② Forward parsed results → buffer.
    _parserSubscription ??= _parser.outputStream.listen(_onParsed);

    // ③ Open the WebSocket channel.
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    try {
      await _channel!.ready; // throws if connection refused
    } catch (e) {
      _scheduleReconnect();
      rethrow; // bubble up on the *first* attempt so callers see the error
    }

    _reconnectAttempts = 0; // reset on successful connect
    _statusCtrl.add(FeedConnectionStatus.connected);

    // ④ Pipe raw WS messages to the parser isolate.
    _wsSubscription = _channel!.stream.listen(
      _onRawMessage,
      onDone:       _handleDisconnect,
      onError:      (_) => _handleDisconnect(),
      cancelOnError: true,
    );

    // ⑤ Start the flush timer.
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_kFlushInterval, (_) => _flush());
  }

  // ── Message handling ──────────────────────────────────────────────────────

  void _onRawMessage(dynamic raw) {
    if (raw is String) _parser.parse(raw);
  }

  /// Called by the parser isolate with decoded maps — stored in buffer.
  void _onParsed(List<Map<String, dynamic>> maps) {
    for (final map in maps) {
      final sym = map['s'];
      if (sym is String) _buffer[sym] = map;
    }
  }

  /// Flushes the buffer and emits a batch to subscribers.
  void _flush() {
    if (_buffer.isEmpty || _tickCtrl.isClosed) return;
    final batch = _buffer.values.map(MarketTickModel.fromMap).toList();
    _buffer.clear();
    _tickCtrl.add(batch);
  }

  // ── Reconnect logic ───────────────────────────────────────────────────────

  void _handleDisconnect() {
    _wsSubscription?.cancel();
    _flushTimer?.cancel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _kReconnectDelays.length) {
      _statusCtrl.add(FeedConnectionStatus.failed);
      return;
    }

    final delaySec = _kReconnectDelays[_reconnectAttempts++];
    _statusCtrl.add(FeedConnectionStatus.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySec), () async {
      if (_lastUrl != null) {
        try {
          await _connect(_lastUrl!);
        } catch (_) {
          // _scheduleReconnect will be called again from _handleDisconnect
        }
      }
    });
  }
}
