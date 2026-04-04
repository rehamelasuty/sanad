import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/market_tick.dart';
import '../repositories/market_feed_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Use-cases  —  thin orchestration wrappers (domain layer)
//
// Each use-case has one responsibility.  The cubit depends on use-cases,
// never directly on the repository.
// ─────────────────────────────────────────────────────────────────────────────

/// Establishes the WebSocket connection to the market feed server.
class ConnectToFeedUseCase {
  const ConnectToFeedUseCase(this._repo);
  final MarketFeedRepository _repo;

  TaskEither<Failure, Unit> call(String wsUrl) => _repo.connect(wsUrl);
}

/// Returns a stream of batched tick updates (throttled to ≤10 Hz).
class WatchTicksUseCase {
  const WatchTicksUseCase(this._repo);
  final MarketFeedRepository _repo;

  Stream<List<MarketTick>> call() => _repo.watchTicks();
}

/// Returns a stream of connection-status changes.
class WatchConnectionStatusUseCase {
  const WatchConnectionStatusUseCase(this._repo);
  final MarketFeedRepository _repo;

  Stream<FeedConnectionStatus> call() => _repo.watchConnectionStatus();
}

/// Closes the WebSocket connection cleanly.
class DisconnectFromFeedUseCase {
  const DisconnectFromFeedUseCase(this._repo);
  final MarketFeedRepository _repo;

  Future<void> call() => _repo.disconnect();
}
