import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dca_plan.dart';
import '../repositories/dca_repository.dart';

class CreateDcaPlanUseCase {
  final DcaRepository _repository;
  const CreateDcaPlanUseCase(this._repository);

  TaskEither<Failure, DcaPlan> call(DcaPlan plan) =>
      _repository.createPlan(plan);
}

class ToggleDcaPlanUseCase {
  final DcaRepository _repository;
  const ToggleDcaPlanUseCase(this._repository);

  TaskEither<Failure, DcaPlan> call(String id, {required bool active}) =>
      _repository.togglePlan(id, active: active);
}
