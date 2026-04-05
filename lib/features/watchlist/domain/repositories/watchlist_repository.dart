// ─────────────────────────────────────────────────────────────────────────────
// WatchlistRepository  —  abstract contract (domain layer)
// ─────────────────────────────────────────────────────────────────────────────

abstract class WatchlistRepository {
  /// Returns the set of bookmarked stock symbols.
  Future<Set<String>> getWatchlist();

  /// Adds [symbol] if not present, removes it if already bookmarked.
  Future<void> toggleSymbol(String symbol);
}
