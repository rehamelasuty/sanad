import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/murabaha_investment.dart';
import '../../domain/entities/murabaha_plan.dart';
import '../../domain/repositories/murabaha_repository.dart';
import '../datasources/murabaha_local_datasource.dart';

class MurabahaRepositoryImpl implements MurabahaRepository {
  const MurabahaRepositoryImpl(this._dataSource);

  final MurabahaLocalDataSource _dataSource;

  @override
  TaskEither<Failure, List<MurabahaPlan>> getPlans() =>
      TaskEither.tryCatch(
        () => _dataSource.getPlans(),
        _mapException,
      );

  @override
  TaskEither<Failure, MurabahaInvestment> invest({
    required MurabahaPlan plan,
    required double amount,
  }) =>
      TaskEither.tryCatch(
        () => _dataSource.invest(plan: plan, amount: amount),
        _mapException,
      );

  @override
  TaskEither<Failure, List<MurabahaInvestment>> getMyInvestments() =>
      TaskEither.tryCatch(
        () => _dataSource.getMyInvestments(),
        _mapException,
      );

  Failure _mapException(Object e, StackTrace _) {
    if (e is NetworkException) return NetworkFailure(e.message, statusCode: e.statusCode);
    if (e is ServerException) return ServerFailure(e.message, statusCode: e.statusCode);
    if (e is CacheException) return CacheFailure(e.message);
    return UnknownFailure(e.toString());
  }
}
