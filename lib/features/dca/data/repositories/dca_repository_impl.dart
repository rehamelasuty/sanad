import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dca_plan.dart';
import '../../domain/repositories/dca_repository.dart';
import '../datasources/dca_local_datasource.dart';

class DcaRepositoryImpl implements DcaRepository {
  final DcaLocalDataSource _dataSource;
  const DcaRepositoryImpl(this._dataSource);

  @override
  TaskEither<Failure, List<DcaPlan>> getPlans() => TaskEither.tryCatch(
        () async => _dataSource.getPlans(),
        (e, _) => CacheFailure(e.toString()),
      );

  @override
  TaskEither<Failure, DcaPlan> createPlan(DcaPlan plan) =>
      TaskEither.tryCatch(
        () async => _dataSource.createPlan(plan),
        (e, _) => CacheFailure(e.toString()),
      );

  @override
  TaskEither<Failure, DcaPlan> togglePlan(String planId,
          {required bool active}) =>
      TaskEither.tryCatch(
        () async => _dataSource.togglePlan(planId, active: active),
        (e, _) => CacheFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> deletePlan(String planId) =>
      TaskEither.tryCatch(
        () async {
          _dataSource.deletePlan(planId);
          return unit;
        },
        (e, _) => CacheFailure(e.toString()),
      );
}
