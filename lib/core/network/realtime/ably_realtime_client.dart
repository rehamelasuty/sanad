import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;

import 'realtime_client_interface.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AblyRealtimeClient
//
// PURPOSE
// ───────
// Implements [IRealtimeClient] by delegating EVERYTHING to the Ably Flutter
// SDK.  Compare the length of this file (~120 lines of logic) with
// [WebSocketRealtimeClient] (~300 lines of logic) to see what Ably gives you
// for free.
//
// WHAT ABLY HANDLES FOR YOU (vs WebSocket doing it manually)
// ───────────────────────────────────────────────────────────
//  ✅  Connection lifecycle + automatic reconnect
//  ✅  Transport selection (WebSocket → HTTP streaming → long-poll fallback)
//  ✅  Application-level heartbeat + dead-connection detection
//  ✅  Channel attach / detach lifecycle
//  ✅  Re-attach channels after reconnect
//  ✅  Message delivery with globally unique UUIDs
//  ✅  Pub/Sub routing (channels.get, channel.subscribe)
//  ✅  Presence (distributed, server-managed member set)
//  ✅  Token auth + automatic token renewal before expiry
//  ✅  Message history (channel.history)
//  ✅  End-to-end encryption (CipherParams — one line to enable)
//  ✅  Message deduplication (idempotent publishing)
//
// HOW TO GET AN API KEY
// ──────────────────────
// 1.  Sign up at https://ably.com (free tier: 6M messages/month)
// 2.  Create an app → copy the API key
// 3.  In production: NEVER embed the key in the app.  Use Ably's token-request
//     flow so the key stays on your server.
//
// SETUP
// ─────
//   dart pub get   (after adding ably_flutter to pubspec.yaml)
//
// ─────────────────────────────────────────────────────────────────────────────

class AblyRealtimeClient implements IRealtimeClient {
  /// [apiKey]   — Ably API key (use token auth in production; see [tokenCallback]).
  /// [clientId] — unique identity for this client (used by presence + auth).
  /// [tokenCallback] — if provided the Ably SDK calls this whenever it needs a
  ///   fresh token, so the API key never leaves your server.
  AblyRealtimeClient({
    String? apiKey,
    required String clientId,
    Future<ably.TokenRequest> Function(ably.TokenParams)? tokenCallback,
  }) {
    assert(
      apiKey != null || tokenCallback != null,
      'Provide either an apiKey or a tokenCallback.',
    );

    // Build ClientOptions — the single configuration object for the Ably SDK.
    // With WebSocket you'd do this across dozens of places in the code.
    final options = ably.ClientOptions(
      clientId: clientId,

      // API key: fine for development, replace with token auth in production.
      key: apiKey,

      // Token auth callback: called automatically by the SDK before expiry.
      // WebSocket equivalent: you write a timer + refresh logic yourself.
      authCallback: tokenCallback != null
          ? (params) async => tokenCallback(params)
          : null,

      // Enable automatic reconnect with the SDK's built-in backoff.
      // WebSocket equivalent: the ~30 lines of _scheduleReconnect() in
      // WebSocketRealtimeClient.
      autoConnect: false, // we call connect() explicitly for control
    );

    _realtime = ably.Realtime(options: options);
  }

  late final ably.Realtime _realtime;

  // ── State management ──────────────────────────────────────────────────────
  // Ably's SDK maintains state internally.  We just translate its enum to ours.
  RealtimeConnectionState _state = RealtimeConnectionState.initialized;
  final _connectionCtrl = StreamController<RealtimeConnectionState>.broadcast();
  StreamSubscription<ably.ConnectionStateChange>? _connStateSub;

  // ── Channel cache ─────────────────────────────────────────────────────────
  // We keep one ably.RealtimeChannel per channel name so we can detach them
  // cleanly on disconnect.
  final Map<String, ably.RealtimeChannel> _channels = {};

  // ─────────────────────────────────────────────────────────────────────────
  // IRealtimeClient — Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  String get clientLabel => 'AblyRealtimeClient';

  @override
  RealtimeConnectionState get connectionState => _state;

  @override
  Stream<RealtimeConnectionState> get connectionStream =>
      _connectionCtrl.stream;

  @override
  Future<void> connect() async {
    if (_state == RealtimeConnectionState.connected) return;

    // Subscribe to connection state changes from the Ably SDK.
    // The SDK emits these automatically — no timers, no manual polling.
    _connStateSub = _realtime.connection.on().listen((change) {
      final mapped = _mapConnectionState(change.current);
      _state = mapped;
      if (!_connectionCtrl.isClosed) _connectionCtrl.add(mapped);
    });

    await _realtime.connect();
    // The SDK handles the full handshake, token fetch, and first heartbeat.
  }

  @override
  Future<void> disconnect() async {
    await _connStateSub?.cancel();
    for (final ch in _channels.values) {
      await ch.detach();
    }
    await _realtime.close();
    _setState(RealtimeConnectionState.disconnected);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IRealtimeClient — Pub/Sub
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Stream<RealtimeMessage> subscribe(String channel, {String? event}) {
    // channels.get() returns a cached channel — no duplicate connections.
    // The SDK attaches to the channel automatically on first subscribe.
    final ch = _getOrAttach(channel);

    // subscribe() returns a Stream<ably.Message> filtered by event name.
    // Pass no name to receive all events.
    final ablyStream = event != null
        ? ch.subscribe(name: event)
        : ch.subscribe();

    // Map ably.Message → our RealtimeMessage type so callers stay decoupled
    // from the Ably SDK type system.
    return ablyStream.map((msg) => RealtimeMessage(
          channel:   channel,
          event:     msg.name ?? '',
          data:      msg.data,
          timestamp: msg.timestamp ?? DateTime.now(),
          clientId:  msg.clientId,
          id:        msg.id,
        ));
  }

  @override
  Future<void> publish({
    required String channel,
    required String event,
    required dynamic data,
  }) async {
    final ch = _getOrAttach(channel);
    // One call.  Ably handles queueing, retry on failure, and deduplication.
    await ch.publish(
      message: ably.Message(name: event, data: data),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IRealtimeClient — Presence
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> enterPresence(String channel, {dynamic data}) async {
    await _getOrAttach(channel).presence.enter(data);
    // The SDK broadcasts the enter event to all subscribers on the channel.
    // With WebSocket you'd send an envelope and write the server-side broadcast.
  }

  @override
  Future<void> leavePresence(String channel) async {
    await _getOrAttach(channel).presence.leave();
  }

  @override
  Future<void> updatePresence(String channel, {required dynamic data}) async {
    await _getOrAttach(channel).presence.update(data);
  }

  @override
  Stream<PresenceEvent> presenceStream(String channel) {
    return _getOrAttach(channel)
        .presence
        .subscribe()
        .map((msg) => _mapPresence(channel, msg));
  }

  @override
  Future<List<PresenceEvent>> getPresence(String channel) async {
    final members = await _getOrAttach(channel).presence.get();
    return members
        .map((m) => _mapPresence(channel, m))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  ably.RealtimeChannel _getOrAttach(String channel) {
    if (!_channels.containsKey(channel)) {
      final ch = _realtime.channels.get(channel);
      _channels[channel] = ch;
      // attach() is idempotent — safe to call even if already attached.
      ch.attach();
    }
    return _channels[channel]!;
  }

  void _setState(RealtimeConnectionState state) {
    _state = state;
    if (!_connectionCtrl.isClosed) _connectionCtrl.add(state);
  }

  // ── Type mappers ──────────────────────────────────────────────────────────

  static RealtimeConnectionState _mapConnectionState(
      ably.ConnectionState state) {
    return switch (state) {
      ably.ConnectionState.initialized   => RealtimeConnectionState.initialized,
      ably.ConnectionState.connecting    => RealtimeConnectionState.connecting,
      ably.ConnectionState.connected     => RealtimeConnectionState.connected,
      ably.ConnectionState.disconnected  => RealtimeConnectionState.reconnecting,
      ably.ConnectionState.suspended     => RealtimeConnectionState.suspended,
      ably.ConnectionState.closing       => RealtimeConnectionState.disconnecting,
      ably.ConnectionState.closed        => RealtimeConnectionState.disconnected,
      ably.ConnectionState.failed        => RealtimeConnectionState.failed,
    };
  }

  static PresenceEvent _mapPresence(
      String channel, ably.PresenceMessage msg) {
    return PresenceEvent(
      channel:   channel,
      clientId:  msg.clientId ?? 'unknown',
      action:    _mapPresenceAction(msg.action),
      data:      msg.data,
      timestamp: msg.timestamp ?? DateTime.now(),
    );
  }

  static PresenceAction _mapPresenceAction(ably.PresenceAction? action) {
    return switch (action) {
      ably.PresenceAction.enter   => PresenceAction.enter,
      ably.PresenceAction.leave   => PresenceAction.leave,
      ably.PresenceAction.update  => PresenceAction.update,
      ably.PresenceAction.present => PresenceAction.present,
      _ => PresenceAction.enter,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await disconnect();
    await _connectionCtrl.close();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADVANCED FEATURES (not available in WebSocketRealtimeClient)
// ─────────────────────────────────────────────────────────────────────────────
//
// ── 1. Message History ────────────────────────────────────────────────────────
//
//   final ch = _realtime.channels.get('market:AAPL');
//   final result = await ch.history(
//     ably.RealtimeHistoryParams(limit: 100, direction: 'backwards'),
//   );
//   final messages = result.items;
//
// ── 2. End-to-End Encryption ─────────────────────────────────────────────────
//
//   final cipherKey = await ably.Crypto.generateRandomKey();
//   final params    = ably.CipherParams(key: cipherKey);
//   final ch        = _realtime.channels.get(
//     'market:AAPL',
//     ably.RealtimeChannelOptions(cipher: params),
//   );
//   // All messages on this channel are encrypted transparently.
//
// ── 3. Push Notifications ────────────────────────────────────────────────────
//
//   await ably.Push.activate();
//   final channel = _realtime.channels.get('push-channel');
//   await channel.push.subscribeDevice();
//   // The device now receives push notifications when offline.
//
// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE
// ─────────────────────────────────────────────────────────────────────────────
//
//   final client = AblyRealtimeClient(
//     apiKey:   'YOUR_API_KEY.YOUR_API_SECRET',  // use tokenCallback in prod!
//     clientId: 'trader-alice',
//   );
//
//   // Identical API to WebSocketRealtimeClient:
//
//   await client.connect();
//
//   client.subscribe('market:AAPL', event: 'tick').listen((msg) {
//     print('Price update: ${msg.data}');
//   });
//
//   await client.publish(
//     channel: 'market:AAPL',
//     event:   'alert',
//     data:    {'price': 200.0, 'direction': 'up'},
//   );
//
//   await client.enterPresence('trading-room', data: {'username': 'Alice'});
//
//   await client.disconnect();
//   await client.dispose();
