import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/asset_allocation.dart';
import '../../domain/entities/portfolio_holding.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  const PortfolioRepositoryImpl(this._dataSource);

  final PortfolioLocalDataSource _dataSource;

  @override
  TaskEither<Failure, List<PortfolioHolding>> getHoldings() =>
      TaskEither.tryCatch(
        () => _dataSource.getHoldings(),
        _mapException,
      );

  @override
  TaskEither<Failure, List<AssetAllocation>> getAssetAllocations() =>
      TaskEither.tryCatch(
        () => _dataSource.getAssetAllocations(),
        _mapException,
      );

  Failure _mapException(Object e, StackTrace _) {
    if (e is NetworkException) return NetworkFailure(e.message, statusCode: e.statusCode);
    if (e is ServerException) return ServerFailure(e.message, statusCode: e.statusCode);
    if (e is CacheException) return CacheFailure(e.message);
    return UnknownFailure(e.toString());
  }
}
