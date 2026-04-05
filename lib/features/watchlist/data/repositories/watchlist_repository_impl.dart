import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WatchlistRepositoryImpl
// ─────────────────────────────────────────────────────────────────────────────

class WatchlistRepositoryImpl implements WatchlistRepository {
  const WatchlistRepositoryImpl(this._ds);

  final WatchlistLocalDatasource _ds;

  @override
  Future<Set<String>> getWatchlist() => _ds.getWatchlist();

  @override
  Future<void> toggleSymbol(String symbol) async {
    final current = await _ds.getWatchlist();
    if (current.contains(symbol)) {
      current.remove(symbol);
    } else {
      current.add(symbol);
    }
    await _ds.save(current);
  }
}
