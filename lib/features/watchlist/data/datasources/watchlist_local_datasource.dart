import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WatchlistLocalDatasource
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class WatchlistLocalDatasource {
  Future<Set<String>> getWatchlist();
  Future<void> save(Set<String> symbols);
}

class WatchlistLocalDatasourceImpl implements WatchlistLocalDatasource {
  static const _key = 'awb_watchlist_v1';

  @override
  Future<Set<String>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  @override
  Future<void> save(Set<String> symbols) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, symbols.toList());
  }
}
