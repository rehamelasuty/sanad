import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/market_tick.dart';
import '../../domain/repositories/market_feed_repository.dart';
import '../../domain/usecases/market_feed_usecases.dart';
import 'market_feed_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketFeedCubit
//
// Data flow
// ─────────
//   connect(url)
//     → ConnectToFeedUseCase.call()          — establishes WebSocket
//     → WatchConnectionStatusUseCase.call()  — status changes → state updates
//     → WatchTicksUseCase.call()             — batched tick stream
//         → _onTickBatch()                  — merges into tickMap, emits
//
// Performance contract
// ────────────────────
// • _onTickBatch runs at ≤10 Hz (throttled in the datasource layer).
// • Map.from() on 1 000 entries ≈ 0.05 ms — negligible.
// • updatesPerSecond is sampled every 1 s (not computed per tick).
// ─────────────────────────────────────────────────────────────────────────────

class MarketFeedCubit extends Cubit<MarketFeedState> {
  MarketFeedCubit({
    required ConnectToFeedUseCase          connect,
    required DisconnectFromFeedUseCase     disconnect,
    required WatchTicksUseCase             watchTicks,
    required WatchConnectionStatusUseCase  watchConnectionStatus,
  })  : _connect              = connect,
        _disconnect           = disconnect,
        _watchTicks           = watchTicks,
        _watchConnectionStatus = watchConnectionStatus,
        super(const MarketFeedInitial());

  final ConnectToFeedUseCase          _connect;
  final DisconnectFromFeedUseCase     _disconnect;
  final WatchTicksUseCase             _watchTicks;
  final WatchConnectionStatusUseCase  _watchConnectionStatus;

  StreamSubscription<List<MarketTick>>?    _tickSub;
  StreamSubscription<FeedConnectionStatus>? _statusSub;

  // Rolling UPS counter
  int    _ticksThisSecond = 0;
  Timer? _upsTimer;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Connect to the market feed at [wsUrl].
  /// Default points to local dev server.
  Future<void> connectToFeed({String wsUrl = 'ws://localhost:8080'}) async {
    emit(const MarketFeedConnecting());

    // ① Subscribe to connection status changes
    _statusSub?.cancel();
    _statusSub = _watchConnectionStatus().listen(_onStatusChange);

    // ② Attempt connection
    final result = await _connect(wsUrl).run();
    result.fold(
      (failure) => emit(MarketFeedError(failure.userMessage)),
      (_) {
        // ③ Start tick subscription on success
        _tickSub?.cancel();
        _tickSub = _watchTicks().listen(_onTickBatch);

        // ④ Start updates-per-second sampler
        _upsTimer?.cancel();
        _upsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          final current = state;
          if (current is MarketFeedConnected) {
            emit(current.copyWith(updatesPerSecond: _ticksThisSecond));
          }
          _ticksThisSecond = 0;
        });
      },
    );
  }

  /// Cleanly disconnect and release all resources.
  Future<void> disconnectFeed() async {
    _upsTimer?.cancel();
    await _tickSub?.cancel();
    await _statusSub?.cancel();
    await _disconnect();
    emit(const MarketFeedDisconnected());
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  /// Called by the status stream — maps [FeedConnectionStatus] to state.
  void _onStatusChange(FeedConnectionStatus status) {
    switch (status) {
      case FeedConnectionStatus.connecting:
        if (state is! MarketFeedConnected) emit(const MarketFeedConnecting());
      case FeedConnectionStatus.reconnecting:
        emit(const MarketFeedReconnecting(attempt: 1, maxAttempts: 5));
      case FeedConnectionStatus.failed:
        emit(const MarketFeedError('تعذّر إعادة الاتصال بخادم السوق'));
      case FeedConnectionStatus.disconnected:
        emit(const MarketFeedDisconnected());
      default:
        break;
    }
  }

  /// Called at ≤10 Hz with a batch of updated ticks.
  ///
  /// Strategy: merge the incoming batch into the existing [tickMap].
  /// The symbols list is set once from the first large batch (server snapshot)
  /// and never changed again, giving the ListView a stable order.
  void _onTickBatch(List<MarketTick> batch) {
    _ticksThisSecond += batch.length;

    final current = state;

    if (current is MarketFeedConnected) {
      // Merge: O(batch.length) — fast regardless of total stock count.
      final newMap = Map<String, MarketTick>.from(current.tickMap);
      for (final tick in batch) {
        newMap[tick.symbol] = tick;
      }
      emit(current.copyWith(
        tickMap:      newMap,
        totalUpdates: current.totalUpdates + batch.length,
      ));
    } else {
      // First batch — initialise the state.
      final tickMap = {for (final t in batch) t.symbol: t};
      final symbols = tickMap.keys.toList()..sort();
      emit(MarketFeedConnected(
        tickMap:          tickMap,
        symbols:          symbols,
        totalUpdates:     batch.length,
        updatesPerSecond: 0,
        connectedAt:      DateTime.now(),
      ));
    }
  }

  // ── Cubit cleanup ─────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    _upsTimer?.cancel();
    await _tickSub?.cancel();
    await _statusSub?.cancel();
    await _disconnect();
    return super.close();
  }
}
