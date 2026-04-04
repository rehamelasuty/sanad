import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/murabaha_investment.dart';
import '../entities/murabaha_plan.dart';
import '../repositories/murabaha_repository.dart';

class InvestInMurabahaUseCase {
  const InvestInMurabahaUseCase(this._repository);

  final MurabahaRepository _repository;

  TaskEither<Failure, MurabahaInvestment> call({
    required MurabahaPlan plan,
    required double amount,
  }) =>
      _repository.invest(plan: plan, amount: amount);
}
