import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:market_server/simulator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Market WebSocket Server
//
// Starts a WebSocket server on port 8080.
//
// Protocol
// ────────
// 1. On new connection  → server sends a FULL snapshot of all stocks.
// 2. Every 100 ms      → server broadcasts a DELTA batch (~300 stocks).
//
// Both messages are JSON arrays of tick objects:
//   [ { "s": "AAPL", "n": "AAPL Capital", "p": 189.50,
//       "c": 0.45, "cp": 0.24, "v": 125000, "t": 1712345678900 }, … ]
//
// Run:
//   cd server && dart pub get && dart run bin/server.dart
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  const stockCount = 1000;
  const port      = 8080;

  final simulator = MarketSimulator(stockCount: stockCount);
  final clients   = <WebSocketChannel>{};

  // ── WebSocket handler ──────────────────────────────────────────────────────
  final wsHandler = webSocketHandler((WebSocketChannel channel) {
    clients.add(channel);

    // ① Send full snapshot to the newly connected client.
    channel.sink.add(jsonEncode(simulator.getSnapshot()));

    // ② Remove client when they disconnect.
    channel.stream.listen(
      (_) {}, // We don't process client→server messages.
      onDone:  () => clients.remove(channel),
      onError: (_) => clients.remove(channel),
      cancelOnError: true,
    );
  });

  // ── Delta broadcast loop ───────────────────────────────────────────────────
  simulator.tickStream.listen((batch) {
    if (clients.isEmpty) return;

    final payload = jsonEncode(batch);
    // Iterate over a snapshot of the set to avoid concurrent modification.
    for (final client in Set<WebSocketChannel>.from(clients)) {
      try {
        client.sink.add(payload);
      } catch (_) {
        // Dead connection — remove it silently.
        clients.remove(client);
      }
    }
  });

  // ── Start server ───────────────────────────────────────────────────────────
  final server = await shelf_io.serve(
    wsHandler,
    InternetAddress.anyIPv4, // 0.0.0.0 — accepts LAN + localhost connections
    port,
  );

  print('');
  print('🚀  Market server running   →  ws://0.0.0.0:${server.port}');
  print('📈  Simulating $stockCount stocks, broadcasting every 100 ms');
  print('');
}
