import 'dart:async';

// ─────────────────────────────────────────────────────────────────────────────
// realtime_client_interface.dart
//
// Shared contract for BOTH realtime implementations:
//   • WebSocketRealtimeClient  — everything built by hand on raw WebSocket
//   • AblyRealtimeClient       — thin wrapper around the Ably Flutter SDK
//
// Having ONE interface means you can swap between the two implementations
// without touching any feature code — only the DI binding changes.
//
// Read REALTIME_COMPARISON.md for the full architectural walkthrough.
// ─────────────────────────────────────────────────────────────────────────────

// ════════════════════════════════════════════════════════════════════════════
// 1.  CONNECTION STATE
// ════════════════════════════════════════════════════════════════════════════

/// Lifecycle states of a realtime connection.
///
/// The state machine looks like this:
///
/// ```
///   initialized
///       │
///       ▼
///   connecting ──────────────────────────────────────────► failed
///       │                                                    ▲
///       ▼                                                    │
///   connected ──► disconnecting ──► disconnected ──► reconnecting
///                                                    │
///                                                    ▼
///                                               (back to connecting)
/// ```
///
/// Ably also adds `suspended` (channel-level pause while the transport is
/// still alive).  The WebSocket implementation maps network errors to
/// `reconnecting` instead, which is functionally equivalent for mobile apps.
enum RealtimeConnectionState {
  /// Client created; no connection attempt yet.
  initialized,

  /// TCP + WebSocket handshake in progress.
  connecting,

  /// Fully connected; messages flow in both directions.
  connected,

  /// `disconnect()` was called; waiting for the close frame to complete.
  disconnecting,

  /// Connection closed cleanly by this client.
  disconnected,

  /// Transport lost; automatic reconnect scheduled.
  reconnecting,

  /// All reconnect attempts exhausted — give up, notify the user.
  failed,

  /// ── Ably-only ─────────────────────────────────────────────────────────
  /// The connection is live but this particular channel is temporarily
  /// suspended (e.g. after a long disconnect where message history expired).
  /// The WebSocket implementation never emits this state.
  suspended,
}

// ════════════════════════════════════════════════════════════════════════════
// 2.  MESSAGE
// ════════════════════════════════════════════════════════════════════════════

/// A single realtime message delivered on a channel.
///
/// Ably populates every field automatically.
/// The WebSocket implementation derives most fields from the JSON envelope
/// it defines itself (see [WebSocketRealtimeClient._encodeMsg]).
class RealtimeMessage {
  const RealtimeMessage({
    required this.channel,
    required this.event,
    required this.data,
    required this.timestamp,
    this.clientId,
    this.id,
  });

  /// Channel the message belongs to  (e.g. `"market:AAPL"`).
  final String channel;

  /// Event name within the channel   (e.g. `"tick"`, `"order-update"`).
  final String event;

  /// Payload — any JSON-serialisable value (Map, List, String, num, …).
  ///
  /// Ably can encrypt this end-to-end with a single [CipherParams] option.
  /// The WebSocket implementation passes it as plain JSON.
  final dynamic data;

  /// When the message was created.
  /// Ably: server-assigned timestamp.
  /// WebSocket: client-side `DateTime.now()` (less reliable under clock skew).
  final DateTime timestamp;

  /// ID of the client that *published* this message.
  /// Ably: derived from the authenticated token.
  /// WebSocket: manually included in the envelope, honour-system only.
  final String? clientId;

  /// Globally unique message ID.
  /// Ably: guaranteed unique + used for idempotent publishing.
  /// WebSocket: a `timestamp+counter` string — unique per client session only.
  final String? id;

  @override
  String toString() =>
      'RealtimeMessage(channel: $channel, event: $event, id: $id)';
}

// ════════════════════════════════════════════════════════════════════════════
// 3.  PRESENCE
// ════════════════════════════════════════════════════════════════════════════

/// What happened to a presence member.
///
/// Ably emits these natively from any channel.
/// The WebSocket implementation has to maintain its own server-side presence
/// table and broadcast deltas to all subscribers — none of that is free.
enum PresenceAction {
  /// A new member entered the channel.
  enter,

  /// A member left (or their connection dropped and the server timed them out).
  leave,

  /// A member updated their presence data without leaving and re-entering.
  update,

  /// Delivered when *first* subscribing — lists all currently present members.
  present,
}

/// One presence event on a channel.
class PresenceEvent {
  const PresenceEvent({
    required this.channel,
    required this.clientId,
    required this.action,
    required this.timestamp,
    this.data,
  });

  final String channel;
  final String clientId;
  final PresenceAction action;

  /// Optional JSON payload (e.g. `{ "username": "Ali", "role": "trader" }`).
  ///
  /// Ably: sent as the `data` field on the presence message.
  /// WebSocket: manually included in the presence envelope.
  final dynamic data;

  final DateTime timestamp;

  @override
  String toString() => 'PresenceEvent(${action.name} $clientId on $channel)';
}

// ════════════════════════════════════════════════════════════════════════════
// 4.  ABSTRACT CLIENT
// ════════════════════════════════════════════════════════════════════════════

/// Common contract shared by [WebSocketRealtimeClient] and [AblyRealtimeClient].
///
/// ─── Feature parity table ────────────────────────────────────────────────
///
/// | Feature           | WebSocketRealtimeClient          | AblyRealtimeClient    |
/// |-------------------|----------------------------------|-----------------------|
/// | Transport         | Raw WebSocket (dart:io)          | WebSocket + fallbacks |
/// | Connect           | Manual handshake                 | SDK-managed           |
/// | Reconnect         | Truncated exp. backoff (manual)  | Automatic + SDK       |
/// | Heartbeat         | App-level ping/pong timer        | Automatic             |
/// | Channel routing   | JSON envelope + Map<key, ctrl>   | channels.get() SDK    |
/// | Message IDs       | timestamp+counter (local)        | UUID (global, server) |
/// | Publish           | send(envelope) manually          | channel.publish()     |
/// | Presence          | Manual server-side table         | Built-in              |
/// | Auth / tokens     | Manual JWT header                | Token auth + renewal  |
/// | Message history   | ❌ Not available                 | channel.history()     |
/// | Encryption        | ❌ Manual AES needed             | ✅ CipherParams E2E   |
/// | Lines of code     | ~300 (this class)                | ~120 (this class)     |
///
/// ─────────────────────────────────────────────────────────────────────────
abstract class IRealtimeClient {
  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Opens the connection using the credentials passed to the constructor.
  ///
  /// Safe to call multiple times — no-ops if already [RealtimeConnectionState.connected].
  Future<void> connect();

  /// Gracefully closes all subscriptions and sends the transport close frame.
  Future<void> disconnect();

  /// Emits the current and every future connection-state transition.
  Stream<RealtimeConnectionState> get connectionStream;

  /// The most recently known connection state (synchronous read).
  RealtimeConnectionState get connectionState;

  // ── Pub / Sub ─────────────────────────────────────────────────────────────

  /// Returns a broadcast [Stream] of messages on [channel] for event [event].
  ///
  /// Pass `event: null` to receive **every** event on the channel.
  ///
  /// Multiple callers with the same [channel]+[event] share the same stream —
  /// no duplicate subscriptions are created on the transport.
  ///
  /// ```dart
  /// // Only tick events:
  /// client.subscribe('market:AAPL', event: 'tick').listen(print);
  ///
  /// // All events on the channel:
  /// client.subscribe('market:AAPL').listen(print);
  /// ```
  Stream<RealtimeMessage> subscribe(String channel, {String? event});

  /// Publishes [data] on [channel] with event name [event].
  ///
  /// Ably guarantees idempotent delivery; WebSocket fires-and-forgets.
  Future<void> publish({
    required String channel,
    required String event,
    required dynamic data,
  });

  // ── Presence ──────────────────────────────────────────────────────────────

  /// Announces this client's presence on [channel] with optional [data].
  ///
  /// Ably: a single SDK call handled atomically.
  /// WebSocket: sends a presence envelope; the server must broadcast it.
  Future<void> enterPresence(String channel, {dynamic data});

  /// Removes this client from the presence set on [channel].
  Future<void> leavePresence(String channel);

  /// Updates presence [data] without a leave+enter round-trip.
  Future<void> updatePresence(String channel, {required dynamic data});

  /// Broadcast stream of [PresenceEvent]s on [channel].
  ///
  /// Emits [PresenceAction.present] events for every already-present member
  /// immediately upon first subscription, then [PresenceAction.enter] /
  /// [PresenceAction.leave] / [PresenceAction.update] as they happen.
  Stream<PresenceEvent> presenceStream(String channel);

  /// Snapshot of members currently present on [channel].
  Future<List<PresenceEvent>> getPresence(String channel);

  // ── Diagnostics ───────────────────────────────────────────────────────────

  /// A human-readable label shown in logs / debug panels.
  String get clientLabel;
}
