import '../../domain/entities/market_tick.dart';
import '../../domain/repositories/market_feed_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketFeedState  —  sealed union
//
// Equality note
// ─────────────
// [MarketFeedConnected] deliberately does NOT extend Equatable.
// This state mutates its [tickMap] on every 100 ms batch.  We want every
// emit() to propagate so that [BlocSelector] widgets get a chance to compare
// their selected slice.  Since Dart uses identity (===) by default for ==,
// each new state object is always "different" → emit always fires.
// [BlocSelector] then performs fine-grained equality on the tiny sub-value
// it extracts (a single [MarketTick]) to decide whether to rebuild.
// ─────────────────────────────────────────────────────────────────────────────

sealed class MarketFeedState {
  const MarketFeedState();
}

// ── Before connect() is called ───────────────────────────────────────────────
final class MarketFeedInitial extends MarketFeedState {
  const MarketFeedInitial();
}

// ── WebSocket handshake in progress ─────────────────────────────────────────
final class MarketFeedConnecting extends MarketFeedState {
  const MarketFeedConnecting();
}

// ── Live feed active ─────────────────────────────────────────────────────────
final class MarketFeedConnected extends MarketFeedState {
  MarketFeedConnected({
    required this.tickMap,
    required this.symbols,
    required this.totalUpdates,
    required this.updatesPerSecond,
    required this.connectedAt,
    int version = 0,
  }) : _version = version;

  /// Latest tick per symbol.  Keys are stable — only values change.
  final Map<String, MarketTick> tickMap;

  /// Alphabetically sorted symbol list.  Populated from the first batch
  /// (server snapshot) and stays fixed — gives the ListView a stable order.
  final List<String> symbols;

  /// Cumulative count of individual tick updates received.
  final int totalUpdates;

  /// Rolling updates-per-second calculated by the cubit.
  final int updatesPerSecond;

  final DateTime connectedAt;

  final int _version; // incremented on every copyWith → always "different"

  MarketFeedConnected copyWith({
    Map<String, MarketTick>? tickMap,
    List<String>? symbols,
    int? totalUpdates,
    int? updatesPerSecond,
  }) {
    return MarketFeedConnected(
      tickMap:          tickMap          ?? this.tickMap,
      symbols:          symbols          ?? this.symbols,
      totalUpdates:     totalUpdates     ?? this.totalUpdates,
      updatesPerSecond: updatesPerSecond ?? this.updatesPerSecond,
      connectedAt:      connectedAt,
      version:          _version + 1,
    );
  }

  // Identity-based equality: every new instance ≠ previous → emit always fires.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketFeedConnected && _version == other._version);

  @override
  int get hashCode => _version.hashCode;
}

// ── Trying to re-establish connection ────────────────────────────────────────
final class MarketFeedReconnecting extends MarketFeedState {
  const MarketFeedReconnecting({required this.attempt, required this.maxAttempts});
  final int attempt;
  final int maxAttempts;
}

// ── WebSocket cleanly closed ─────────────────────────────────────────────────
final class MarketFeedDisconnected extends MarketFeedState {
  const MarketFeedDisconnected();
}

// ── Unrecoverable error ───────────────────────────────────────────────────────
final class MarketFeedError extends MarketFeedState {
  const MarketFeedError(this.message);
  final String message;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers used by UI
// ─────────────────────────────────────────────────────────────────────────────

extension FeedConnectionStatusX on FeedConnectionStatus {
  String get label => switch (this) {
    FeedConnectionStatus.initial       => 'غير متصل',
    FeedConnectionStatus.connecting    => 'جاري الاتصال…',
    FeedConnectionStatus.connected     => 'متصل',
    FeedConnectionStatus.reconnecting  => 'إعادة الاتصال…',
    FeedConnectionStatus.disconnected  => 'منقطع',
    FeedConnectionStatus.failed        => 'فشل الاتصال',
  };
}
