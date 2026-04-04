import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dca_plan.dart';
import '../repositories/dca_repository.dart';

class GetDcaPlansUseCase {
  final DcaRepository _repository;
  const GetDcaPlansUseCase(this._repository);

  TaskEither<Failure, List<DcaPlan>> call() => _repository.getPlans();
}
