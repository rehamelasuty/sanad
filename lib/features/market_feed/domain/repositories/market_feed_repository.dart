import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/market_tick.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketFeedRepository  —  abstract contract (domain layer)
//
// The domain layer only knows about this interface, never about
// WebSockets or JSON.  Implementations live in the data layer.
// ─────────────────────────────────────────────────────────────────────────────

/// WebSocket connection lifecycle states.
enum FeedConnectionStatus {
  initial,        // not yet connected
  connecting,     // handshake in progress
  connected,      // live feed active
  reconnecting,   // lost connection, retrying
  disconnected,   // cleanly closed
  failed,         // max reconnect attempts reached
}

abstract class MarketFeedRepository {
  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Opens a WebSocket connection to [wsUrl] and begins receiving ticks.
  /// Returns [NetworkFailure] if the connection cannot be established.
  TaskEither<Failure, Unit> connect(String wsUrl);

  /// Closes the WebSocket connection and releases all resources.
  Future<void> disconnect();

  // ── Data streams ─────────────────────────────────────────────────────────

  /// Emits batched tick updates at most every 100 ms.
  /// Each emission contains ALL stocks whose price changed in that window.
  /// Heavy JSON parsing runs on a background [Isolate] — this stream is
  /// safe to subscribe to from the main/UI isolate.
  Stream<List<MarketTick>> watchTicks();

  /// Emits the current [FeedConnectionStatus] whenever it changes.
  Stream<FeedConnectionStatus> watchConnectionStatus();
}
