import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/watchlist_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WatchlistCubit
//
// State is a plain Set<String> of bookmarked symbols.
// Provided at app level — accessible anywhere via context.read<WatchlistCubit>().
// ─────────────────────────────────────────────────────────────────────────────

class WatchlistCubit extends Cubit<Set<String>> {
  WatchlistCubit(this._repo) : super(const {});

  final WatchlistRepository _repo;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load persisted watchlist on app start.
  Future<void> load() async {
    final symbols = await _repo.getWatchlist();
    emit(Set.unmodifiable(symbols));
  }

  /// Add symbol if not watched, remove it if already watched.
  Future<void> toggle(String symbol) async {
    await _repo.toggleSymbol(symbol);
    final symbols = await _repo.getWatchlist();
    emit(Set.unmodifiable(symbols));
  }

  /// Reactive check — use inside BlocBuilder or BlocSelector.
  bool isWatched(String symbol) => state.contains(symbol);
}
