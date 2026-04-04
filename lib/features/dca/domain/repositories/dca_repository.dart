import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dca_plan.dart';

abstract class DcaRepository {
  TaskEither<Failure, List<DcaPlan>> getPlans();
  TaskEither<Failure, DcaPlan> createPlan(DcaPlan plan);
  TaskEither<Failure, DcaPlan> togglePlan(String planId, {required bool active});
  TaskEither<Failure, Unit> deletePlan(String planId);
}
