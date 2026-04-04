import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _dataSource;

  const HomeRepositoryImpl(this._dataSource);

  @override
  TaskEither<Failure, PortfolioSummary> getPortfolioSummary() =>
      TaskEither.tryCatch(
        () => _dataSource.getPortfolioSummary(),
        _mapException,
      );

  @override
  TaskEither<Failure, List<WatchlistItem>> getWatchlist() =>
      TaskEither.tryCatch(
        () => _dataSource.getWatchlist(),
        _mapException,
      );

  Failure _mapException(Object e, StackTrace st) {
    if (e is NetworkException) return NetworkFailure(e.message, statusCode: e.statusCode);
    if (e is ServerException) return ServerFailure(e.message, statusCode: e.statusCode);
    if (e is CacheException) return CacheFailure(e.message);
    return UnknownFailure(e.toString());
  }
}
