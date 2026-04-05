import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'realtime_client_interface.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WebSocketRealtimeClient
//
// PURPOSE
// ───────
// Implements every feature of [IRealtimeClient] using nothing but a raw
// WebSocket connection.  There is NO helper library for channels, presence,
// reconnect, or auth — we write every line ourselves.
//
// This implementation exists specifically to show the contrast with
// [AblyRealtimeClient].  Read REALTIME_COMPARISON.md for the full breakdown.
//
// WHAT YOU BUILD MANUALLY (vs Ably doing it for you)
// ───────────────────────────────────────────────────
//  1.  Message envelope protocol    (JSON schema the server must also speak)
//  2.  Channel / event routing       (Map of StreamControllers)
//  3.  Reconnect with backoff        (truncated exponential, manual timer)
//  4.  Application-level heartbeat   (ping/pong over the data channel)
//  5.  Presence table                (client-side merge of server events)
//  6.  Message deduplication         (client-side timestamp+counter IDs)
//  7.  Re-subscription after reconnect (re-send all subscribe frames)
//
// MESSAGE PROTOCOL  (client ↔ server must agree on this JSON schema)
// ────────────────────────────────────────────────────────────────────
// The protocol is a simple JSON envelope.  Ably has an equivalent built
// into its SDK and wire format so you never think about it.
//
//   CLIENT → SERVER
//   ┌─────────────────────────────────────────────────────────────────┐
//   │ { "t": "sub",  "ch": "market:AAPL", "ev": "tick"           }  │  subscribe
//   │ { "t": "sub",  "ch": "market:AAPL"                          }  │  subscribe all
//   │ { "t": "unsub","ch": "market:AAPL"                          }  │  unsubscribe
//   │ { "t": "msg",  "ch": "market:AAPL", "ev": "tick",           │
//   │         "d": {...}, "id": "1712..._1", "cid": "alice"       }  │  publish
//   │ { "t": "presence", "a": "enter", "ch": "room", "d": {...}  }  │  enter
//   │ { "t": "presence", "a": "leave", "ch": "room"              }  │  leave
//   │ { "t": "presence", "a": "update","ch": "room", "d": {...}  }  │  update
//   │ { "t": "ping"                                               }  │  heartbeat
//   └─────────────────────────────────────────────────────────────────┘
//
//   SERVER → CLIENT
//   ┌─────────────────────────────────────────────────────────────────┐
//   │ { "t": "msg", "ch": "market:AAPL", "ev": "tick",            │
//   │       "d": {...}, "id": "...", "cid": "...", "ts": 1712...  }  │  incoming msg
//   │ { "t": "presence", "a": "enter", "ch": "room",              │
//   │       "cid": "bob", "d": {...}, "ts": 1712...               }  │  presence
//   │ { "t": "presence", "a": "present", "ch": "room",            │
//   │       "cid": "alice", "d": {...}, "ts": 1712...             }  │  initial snapshot
//   │ { "t": "pong"                                               }  │  heartbeat reply
//   │ { "t": "ack",  "ch": "market:AAPL"                          }  │  subscribe ACK
//   │ { "t": "err",  "code": 401, "msg": "Unauthorized"           }  │  error
//   └─────────────────────────────────────────────────────────────────┘
//
// RECONNECT STRATEGY  (truncated exponential backoff)
// ─────────────────────────────────────────────────────
//   attempt 1 →  2 s
//   attempt 2 →  4 s
//   attempt 3 →  8 s
//   attempt 4 → 16 s
//   attempt 5 → 30 s  (cap)
//   attempt 6 → emit failed, stop
//
// HEARTBEAT
// ─────────
// The server-side TCP stack may silently drop idle connections after ~60 s.
// A WebSocket has NO built-in keepalive at the application layer.  We send
// a "ping" JSON frame every [_kHeartbeatInterval]; if no "pong" arrives
// within [_kHeartbeatTimeout] we treat it as a disconnect and reconnect.
// ─────────────────────────────────────────────────────────────────────────────

// ── Timing constants ──────────────────────────────────────────────────────────
const _kHeartbeatInterval = Duration(seconds: 20);
const _kHeartbeatTimeout  = Duration(seconds: 10);
const _kReconnectDelays   = [2, 4, 8, 16, 30]; // seconds

// ── Envelope type field values ────────────────────────────────────────────────
const _tMsg      = 'msg';
const _tSub      = 'sub';
const _tPresence = 'presence';
const _tPing     = 'ping';
const _tPong     = 'pong';

// ─────────────────────────────────────────────────────────────────────────────
// WebSocketRealtimeClient
// ─────────────────────────────────────────────────────────────────────────────

class WebSocketRealtimeClient implements IRealtimeClient {
  /// [url]      — WebSocket endpoint, e.g. `ws://localhost:8080`
  /// [clientId] — this client's identity (sent in publish envelopes)
  /// [getAuthToken] — optional async callback that returns a JWT / API key
  ///   which will be sent as a query parameter `?token=...` on connect.
  ///   WebSocket has no built-in auth — we bolt it on in the URL ourselves.
  WebSocketRealtimeClient({
    required String url,
    required String clientId,
    Future<String?> Function()? getAuthToken,
  })  : _baseUrl    = url,
        _clientId   = clientId,
        _getAuthToken = getAuthToken;

  final String _baseUrl;
  final String _clientId;
  final Future<String?> Function()? _getAuthToken;

  // ── Connection internals ──────────────────────────────────────────────────
  WebSocketChannel?   _channel;
  StreamSubscription? _wsSubscription;
  int  _reconnectAttempts = 0;
  bool _intentionalDisconnect = false;
  Timer? _reconnectTimer;

  // ── Heartbeat internals ───────────────────────────────────────────────────
  // WebSocket has NO built-in keepalive at the application layer.
  // We implement it entirely ourselves with two timers.
  Timer? _heartbeatTimer;   // fires every _kHeartbeatInterval → sends "ping"
  Timer? _pongTimer;        // started on ping, cancelled on pong; if it fires → reconnect
  bool   _waitingForPong = false;

  // ── Connection state stream ───────────────────────────────────────────────
  RealtimeConnectionState _state = RealtimeConnectionState.initialized;
  final _connectionCtrl = StreamController<RealtimeConnectionState>.broadcast();

  // ── Message routing ───────────────────────────────────────────────────────
  // Key format:  "$channel\x00$event"  or  "$channel\x00*"  for wildcard.
  //
  // Ably does all of this inside the SDK.  Here we maintain the entire
  // routing table ourselves.
  final Map<String, StreamController<RealtimeMessage>> _msgControllers = {};

  // Track which channels this client has subscribed to so we can
  // re-send subscribe frames after a reconnect.
  final Map<String, Set<String?>> _activeSubscriptions = {};
  //                                     ↑ channel   ↑ Set of event names (null = wildcard)

  // ── Presence ─────────────────────────────────────────────────────────────
  // Ably maintains a real-time distributed presence set on its servers.
  // Here we maintain our own local copy, merging server-sent events.
  final Map<String, Map<String, PresenceEvent>> _presenceTable = {};
  //           ↑ channel        ↑ clientId
  final Map<String, StreamController<PresenceEvent>> _presenceControllers = {};

  // ── Message ID counter ────────────────────────────────────────────────────
  // Ably generates globally-unique UUIDs server-side.
  // We generate a session-scoped ID that's "unique enough" for deduplication.
  int _msgCounter = 0;

  // ─────────────────────────────────────────────────────────────────────────
  // IRealtimeClient — Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  String get clientLabel => 'WebSocketRealtimeClient';

  @override
  RealtimeConnectionState get connectionState => _state;

  @override
  Stream<RealtimeConnectionState> get connectionStream =>
      _connectionCtrl.stream;

  @override
  Future<void> connect() async {
    if (_state == RealtimeConnectionState.connected) return;
    _intentionalDisconnect = false;
    _reconnectAttempts = 0;
    await _attemptConnect();
  }

  @override
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _cancelTimers();
    await _wsSubscription?.cancel();
    await _channel?.sink.close();
    _setState(RealtimeConnectionState.disconnected);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IRealtimeClient — Pub/Sub
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Stream<RealtimeMessage> subscribe(String channel, {String? event}) {
    final key  = _subKey(channel, event);
    final ctrl = _msgControllers.putIfAbsent(
      key,
      () => StreamController<RealtimeMessage>.broadcast(),
    );

    // Track which (channel, event) combos are active so we can re-subscribe
    // after a reconnect.  Ably handles this automatically inside the SDK.
    _activeSubscriptions.putIfAbsent(channel, () => {}).add(event);

    // Tell the server we want messages on this channel+event.
    // If we're not connected yet this fires once the connection opens,
    // because [_resubscribeAll] is called in [_onConnected].
    if (_state == RealtimeConnectionState.connected) {
      _sendSubscribeFrame(channel, event);
    }

    return ctrl.stream;
  }

  @override
  Future<void> publish({
    required String channel,
    required String event,
    required dynamic data,
  }) async {
    _assertConnected();
    _send(_encodeMsg(channel, event, data));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IRealtimeClient — Presence
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> enterPresence(String channel, {dynamic data}) async {
    _assertConnected();
    _send(jsonEncode({
      't':   _tPresence,
      'a':   'enter',
      'ch':  channel,
      'cid': _clientId,
      if (data != null) 'd': data,
    }));
  }

  @override
  Future<void> leavePresence(String channel) async {
    _assertConnected();
    _send(jsonEncode({
      't':   _tPresence,
      'a':   'leave',
      'ch':  channel,
      'cid': _clientId,
    }));
  }

  @override
  Future<void> updatePresence(String channel, {required dynamic data}) async {
    _assertConnected();
    _send(jsonEncode({
      't':   _tPresence,
      'a':   'update',
      'ch':  channel,
      'cid': _clientId,
      'd':   data,
    }));
  }

  @override
  Stream<PresenceEvent> presenceStream(String channel) {
    return _presenceControllers
        .putIfAbsent(
          channel,
          () => StreamController<PresenceEvent>.broadcast(),
        )
        .stream;
  }

  @override
  Future<List<PresenceEvent>> getPresence(String channel) async {
    // Return a snapshot of our local presence table for this channel.
    // Ably fetches this from its servers; we only know what the server
    // has told us so far.
    return (_presenceTable[channel]?.values.toList()) ?? [];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Connection management
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _attemptConnect() async {
    _setState(
      _reconnectAttempts == 0
          ? RealtimeConnectionState.connecting
          : RealtimeConnectionState.reconnecting,
    );

    // ── Auth: bolt a token onto the URL (no native WS auth mechanism) ──────
    // Ably supports token auth, JWT, and API key auth natively.
    // With raw WebSocket we have two options: URL query param or a first-
    // message auth frame. We use the query param approach here.
    String connectUrl = _baseUrl;
    if (_getAuthToken != null) {
      final token = await _getAuthToken();
      if (token != null) {
        final separator = connectUrl.contains('?') ? '&' : '?';
        connectUrl = '$connectUrl${separator}token=$token';
      }
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(connectUrl));
      await _channel!.ready; // throws if the server refused the connection
    } catch (e) {
      _scheduleReconnect();
      if (_reconnectAttempts == 1) rethrow; // surface on the first attempt
      return;
    }

    _onConnected();
  }

  void _onConnected() {
    _reconnectAttempts = 0;
    _setState(RealtimeConnectionState.connected);

    // Re-subscribe to all channels — the server has no memory of us after
    // a reconnect.  Ably handles this automatically inside the SDK.
    _resubscribeAll();

    // Start the application-level heartbeat.
    // Ably does this for you; with raw WebSocket it's your responsibility.
    _startHeartbeat();

    _wsSubscription = _channel!.stream.listen(
      _onRawFrame,
      onDone:        _onTransportClosed,
      onError:       (_) => _onTransportClosed(),
      cancelOnError: true,
    );
  }

  void _onTransportClosed() {
    if (_intentionalDisconnect) return;
    _cancelTimers();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _kReconnectDelays.length) {
      _setState(RealtimeConnectionState.failed);
      return;
    }

    final delaySec = _kReconnectDelays[_reconnectAttempts++];
    _setState(RealtimeConnectionState.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySec), () async {
      try {
        await _attemptConnect();
      } catch (_) {
        // _scheduleReconnect will be called again from _onTransportClosed
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Heartbeat  (application-level ping/pong)
  //
  // The WebSocket spec defines a PING/PONG control frame at the protocol
  // level, but `web_socket_channel` does not expose it directly.
  // We implement an equivalent in the application layer: a JSON { "t":"ping" }
  // message that the server must echo back as { "t":"pong" }.
  //
  // If the pong doesn't arrive within [_kHeartbeatTimeout], we treat the
  // connection as dead and reconnect.
  //
  // Ably's SDK handles keepalive transparently — you never write this code.
  // ─────────────────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_kHeartbeatInterval, (_) => _sendPing());
  }

  void _sendPing() {
    if (_waitingForPong) {
      // Previous pong never arrived — connection is dead.
      _onTransportClosed();
      return;
    }
    _send(jsonEncode({'t': _tPing}));
    _waitingForPong = true;

    _pongTimer?.cancel();
    _pongTimer = Timer(_kHeartbeatTimeout, () {
      if (_waitingForPong) _onTransportClosed();
    });
  }

  void _handlePong() {
    _waitingForPong = false;
    _pongTimer?.cancel();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Incoming frame routing
  //
  // Every frame from the server is a JSON string.  We decode it and route
  // based on the "t" (type) field.
  //
  // Ably's protocol (Ably Real-time Wire Protocol) does all of this routing
  // inside the SDK.  Here we write the entire dispatch table ourselves.
  // ─────────────────────────────────────────────────────────────────────────

  void _onRawFrame(dynamic raw) {
    if (raw is! String) return;

    final Map<String, dynamic> frame;
    try {
      frame = (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return; // malformed frame — ignore
    }

    final type = frame['t'] as String?;
    switch (type) {
      case _tMsg:
        _routeMessage(frame);
      case _tPresence:
        _routePresence(frame);
      case _tPong:
        _handlePong();
      // 'ack' and 'err' frames could be handled here for reliability
      // (e.g., retransmit on error).  Ably handles retries automatically.
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Message routing
  //
  // Ably has a channel abstraction built into the SDK.
  // Here we route manually using a Map<subKey, StreamController>.
  // ─────────────────────────────────────────────────────────────────────────

  void _routeMessage(Map<String, dynamic> frame) {
    final channel = frame['ch']  as String?;
    final event   = frame['ev']  as String?;
    final data    = frame['d'];
    final ts      = frame['ts'];
    final cid     = frame['cid'] as String?;
    final id      = frame['id']  as String?;

    if (channel == null || event == null) return;

    final timestamp = ts is int
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.now();

    final message = RealtimeMessage(
      channel:   channel,
      event:     event,
      data:      data,
      timestamp: timestamp,
      clientId:  cid,
      id:        id,
    );

    // Route to the event-specific subscriber.
    _msgControllers[_subKey(channel, event)]?.add(message);

    // Route to any wildcard subscriber on this channel.
    _msgControllers[_subKey(channel, null)]?.add(message);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Presence routing
  //
  // Ably maintains a distributed presence set on its infrastructure.
  // Here we maintain our own local copy by merging server-sent events.
  // The server must also implement the presence broadcast logic.
  // ─────────────────────────────────────────────────────────────────────────

  void _routePresence(Map<String, dynamic> frame) {
    final channel  = frame['ch']  as String?;
    final clientId = frame['cid'] as String?;
    final actionRaw= frame['a']   as String?;
    final data     = frame['d'];
    final ts       = frame['ts'];

    if (channel == null || clientId == null || actionRaw == null) return;

    final action = _parsePresenceAction(actionRaw);
    final timestamp = ts is int
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.now();

    final event = PresenceEvent(
      channel:  channel,
      clientId: clientId,
      action:   action,
      data:     data,
      timestamp: timestamp,
    );

    // Merge into the local presence table.
    _presenceTable.putIfAbsent(channel, () => {});
    switch (action) {
      case PresenceAction.enter:
      case PresenceAction.present:
      case PresenceAction.update:
        _presenceTable[channel]![clientId] = event;
      case PresenceAction.leave:
        _presenceTable[channel]!.remove(clientId);
    }

    // Broadcast to presence stream subscribers.
    _presenceControllers[channel]?.add(event);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Re-subscription after reconnect
  //
  // After a reconnect the server has NO memory of what this client subscribed
  // to — we must re-send every subscribe frame.
  // Ably tracks channel state inside the SDK and automatically re-attaches.
  // ─────────────────────────────────────────────────────────────────────────

  void _resubscribeAll() {
    for (final entry in _activeSubscriptions.entries) {
      final channel = entry.key;
      for (final event in entry.value) {
        _sendSubscribeFrame(channel, event);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Encoding helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _sendSubscribeFrame(String channel, String? event) {
    _send(jsonEncode({
      't':  _tSub,
      'ch': channel,
      if (event != null) 'ev': event,
    }));
  }

  /// Encodes a publish envelope with a local message ID.
  ///
  /// Ably generates UUIDs server-side and guarantees global uniqueness.
  /// Our IDs are `"<epochMs>_<counter>"` — unique only within this session.
  String _encodeMsg(String channel, String event, dynamic data) {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${_msgCounter++}';
    return jsonEncode({
      't':   _tMsg,
      'ch':  channel,
      'ev':  event,
      'd':   data,
      'id':  id,
      'cid': _clientId,
    });
  }

  void _send(String payload) {
    _channel?.sink.add(payload);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Subscription routing key.
  /// `null` event means "subscribe to all events on this channel".
  static String _subKey(String channel, String? event) =>
      '$channel\x00${event ?? '*'}';

  void _setState(RealtimeConnectionState state) {
    _state = state;
    if (!_connectionCtrl.isClosed) _connectionCtrl.add(state);
  }

  void _assertConnected() {
    if (_state != RealtimeConnectionState.connected) {
      throw StateError(
        'WebSocketRealtimeClient: publish/presence called while not connected '
        '(current state: ${_state.name}).',
      );
    }
  }

  void _cancelTimers() {
    _heartbeatTimer?.cancel();
    _pongTimer?.cancel();
    _reconnectTimer?.cancel();
    _waitingForPong = false;
  }

  static PresenceAction _parsePresenceAction(String raw) {
    return switch (raw) {
      'enter'   => PresenceAction.enter,
      'leave'   => PresenceAction.leave,
      'update'  => PresenceAction.update,
      'present' => PresenceAction.present,
      _         => PresenceAction.enter,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────────────────────

  /// Releases all resources.  Call this when the object is no longer needed
  /// (e.g. in State.dispose or a BLoC close).
  Future<void> dispose() async {
    await disconnect();
    for (final ctrl in _msgControllers.values)      { await ctrl.close(); }
    for (final ctrl in _presenceControllers.values) { await ctrl.close(); }
    await _connectionCtrl.close();
    _msgControllers.clear();
    _presenceControllers.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE  (copy this into your BLoC or repository)
// ─────────────────────────────────────────────────────────────────────────────
//
//   final client = WebSocketRealtimeClient(
//     url:          'ws://localhost:8080',
//     clientId:     'trader-alice',
//     getAuthToken: () async => await authService.getJwt(),
//   );
//
//   // 1. Connect
//   await client.connect();
//
//   // 2. Subscribe to "tick" events on the AAPL channel
//   client.subscribe('market:AAPL', event: 'tick').listen((msg) {
//     print('Price update: ${msg.data}');
//   });
//
//   // 3. Subscribe to ALL events on a channel (wildcard)
//   client.subscribe('orders').listen((msg) {
//     print('Order event [${msg.event}]: ${msg.data}');
//   });
//
//   // 4. Publish
//   await client.publish(
//     channel: 'market:AAPL',
//     event:   'alert',
//     data:    {'price': 200.0, 'direction': 'up'},
//   );
//
//   // 5. Presence
//   await client.enterPresence('trading-room', data: {'username': 'Alice'});
//   client.presenceStream('trading-room').listen((e) {
//     print('${e.action.name} ${e.clientId}');
//   });
//
//   // 6. Disconnect
//   await client.disconnect();
//   await client.dispose();
