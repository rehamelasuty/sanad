import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/market_index.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/markets_repository.dart';
import '../datasources/markets_local_datasource.dart';

class MarketsRepositoryImpl implements MarketsRepository {
  final MarketsLocalDataSource _dataSource;

  const MarketsRepositoryImpl(this._dataSource);

  @override
  TaskEither<Failure, List<Stock>> getStocks({String? category}) =>
      TaskEither.tryCatch(
        () => _dataSource.getStocks(category: category),
        _mapException,
      );

  @override
  TaskEither<Failure, List<MarketIndex>> getMarketIndices() =>
      TaskEither.tryCatch(
        () => _dataSource.getMarketIndices(),
        _mapException,
      );

  Failure _mapException(Object e, StackTrace st) {
    if (e is NetworkException) return NetworkFailure(e.message, statusCode: e.statusCode);
    if (e is ServerException) return ServerFailure(e.message, statusCode: e.statusCode);
    if (e is CacheException) return CacheFailure(e.message);
    return UnknownFailure(e.toString());
  }
}
