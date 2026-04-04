import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/murabaha_investment.dart';
import '../entities/murabaha_plan.dart';

abstract interface class MurabahaRepository {
  TaskEither<Failure, List<MurabahaPlan>> getPlans();

  TaskEither<Failure, MurabahaInvestment> invest({
    required MurabahaPlan plan,
    required double amount,
  });

  TaskEither<Failure, List<MurabahaInvestment>> getMyInvestments();
}
