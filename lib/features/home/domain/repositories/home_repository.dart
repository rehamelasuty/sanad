import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/portfolio_summary.dart';
import '../entities/watchlist_item.dart';

abstract interface class HomeRepository {
  TaskEither<Failure, PortfolioSummary> getPortfolioSummary();
  TaskEither<Failure, List<WatchlistItem>> getWatchlist();
}
