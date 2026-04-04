import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

// ─────────────────────────────────────────────────────────────────────────────
// TickParserWorker  —  persistent background Isolate for JSON parsing
//
// Problem
// ───────
// The market server sends batches of ~300 ticks every 100 ms.
// A batch is roughly 300 × 100 bytes ≈ 30 KB of JSON.
// Calling jsonDecode() on 30 KB on the main thread takes ~1–3 ms and
// causes visible jank at 60 fps (budget = 16 ms/frame).
//
// Solution
// ────────
// Spawn ONE long-lived Isolate at startup.  Every raw JSON string is
// forwarded to that isolate via a SendPort.  The isolate decodes it and
// sends back a List<Map<String, dynamic>> via its own SendPort.
//
// Choosing a *persistent* isolate over compute() avoids the overhead of
// spawning and killing an isolate for every message (~5–15 ms each time).
//
// Communication pattern
// ─────────────────────
//   Main  ──[setup SendPort]──▶  Worker  (initial handshake)
//   Main  ◀──[worker SendPort]──  Worker  (handshake reply)
//   Main  ──[raw JSON String]──▶  Worker  (parse request)
//   Main  ◀──[parsed List<Map>]──  Worker  (parse result)
//   Main  ──[_kShutdown]──▶  Worker          (clean teardown)
//
// Two separate ReceivePorts are used so the handshake and results never
// mix on the same stream.
// ─────────────────────────────────────────────────────────────────────────────

const _kShutdown = 'shutdown';

// ── Isolate entry-point (must be top-level — no closures over state) ─────────

/// Called by [Isolate.spawn].  Receives TWO [SendPort]s packaged as a List:
///   ports[0] = handshakeSendPort  → used once to send back the worker's port
///   ports[1] = resultsSendPort    → used for every parsed-batch reply
@pragma('vm:entry-point')
void _tickParserEntryPoint(List<SendPort> ports) {
  final handshakeSendPort = ports[0];
  final resultsSendPort   = ports[1];

  final workerReceivePort = ReceivePort();

  // Reply with our receive port so the main isolate can send us messages.
  handshakeSendPort.send(workerReceivePort.sendPort);

  workerReceivePort.listen((dynamic message) {
    if (message == _kShutdown) {
      workerReceivePort.close();
      return;
    }

    if (message is! String) return;

    try {
      final decoded = jsonDecode(message);
      if (decoded is List) {
        // Cast to the expected type and ship back to main isolate.
        resultsSendPort.send(decoded.cast<Map<String, dynamic>>());
      }
    } catch (_) {
      // Silently skip malformed JSON — never crash the worker.
    }
  });
}

// ── Worker wrapper (used from main isolate) ───────────────────────────────────

/// Manages the lifecycle of the background parser isolate.
///
/// Usage:
/// ```dart
/// final worker = TickParserWorker();
/// await worker.init();
///
/// worker.outputStream.listen((maps) { /* process parsed maps */ });
/// worker.parse(rawJsonString);
///
/// await worker.dispose();
/// ```
class TickParserWorker {
  late final Isolate   _isolate;
  late final SendPort  _workerSendPort;

  // Results from the worker are emitted on this stream.
  final _outputCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get outputStream => _outputCtrl.stream;

  bool _ready     = false;
  bool _disposed  = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Spawns the background isolate and performs the handshake.
  /// Must be called once before [parse].
  Future<void> init() async {
    // Port 1: used only for the initial handshake.
    final handshakeReceivePort = ReceivePort();

    // Port 2: used for every parse-result reply.
    final resultsReceivePort = ReceivePort();

    _isolate = await Isolate.spawn<List<SendPort>>(
      _tickParserEntryPoint,
      [handshakeReceivePort.sendPort, resultsReceivePort.sendPort],
      debugName: 'TickParserWorker',
    );

    // Block until the worker sends back its own receive port.
    _workerSendPort = await handshakeReceivePort.first as SendPort;
    handshakeReceivePort.close(); // one-shot port — close immediately

    // Forward every result from the worker to our output stream.
    resultsReceivePort.listen((dynamic msg) {
      if (!_outputCtrl.isClosed) {
        _outputCtrl.add(msg as List<Map<String, dynamic>>);
      }
    });

    _ready = true;
  }

  /// Sends [rawJson] to the worker isolate for parsing.
  /// The parsed result will be emitted on [outputStream].
  void parse(String rawJson) {
    if (_ready && !_disposed) {
      _workerSendPort.send(rawJson);
    }
  }

  /// Shuts down the worker isolate and closes all resources.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _ready    = false;
    if (!_outputCtrl.isClosed) await _outputCtrl.close();
    try {
      _workerSendPort.send(_kShutdown);
    } catch (_) {}
    _isolate.kill(priority: Isolate.immediate);
  }
}
