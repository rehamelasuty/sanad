import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/murabaha_plan.dart';
import '../repositories/murabaha_repository.dart';

class GetMurabahaPlansUseCase {
  const GetMurabahaPlansUseCase(this._repository);

  final MurabahaRepository _repository;

  TaskEither<Failure, List<MurabahaPlan>> call() => _repository.getPlans();
}
