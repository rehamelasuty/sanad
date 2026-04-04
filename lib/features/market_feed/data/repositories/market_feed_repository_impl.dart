import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/market_tick.dart';
import '../../domain/repositories/market_feed_repository.dart';
import '../datasources/market_websocket_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketFeedRepositoryImpl  —  bridges domain ↔ data
//
// Maps exceptions from the datasource to typed [Failure] values, and
// converts [MarketTickModel]s (data layer) to [MarketTick]s (domain layer).
// Since [MarketTickModel] extends [MarketTick], no field mapping is needed —
// this is just a type-safe upcast.
// ─────────────────────────────────────────────────────────────────────────────

class MarketFeedRepositoryImpl implements MarketFeedRepository {
  MarketFeedRepositoryImpl(this._datasource);

  final MarketWebSocketDatasource _datasource;

  @override
  TaskEither<Failure, Unit> connect(String wsUrl) =>
      TaskEither.tryCatch(
        () async {
          await _datasource.connect(wsUrl);
          return unit;
        },
        (e, _) => NetworkFailure('Failed to connect to market feed: $e'),
      );

  @override
  Future<void> disconnect() => _datasource.disconnect();

  @override
  Stream<List<MarketTick>> watchTicks() =>
      // MarketTickModel extends MarketTick — safe upcast
      _datasource.tickStream.map(
        (models) => models.cast<MarketTick>(),
      );

  @override
  Stream<FeedConnectionStatus> watchConnectionStatus() =>
      _datasource.statusStream;
}
