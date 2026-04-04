import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/investment_fund.dart';
import '../repositories/funds_repository.dart';

class GetFundsUseCase {
  final FundsRepository _repository;
  const GetFundsUseCase(this._repository);

  TaskEither<Failure, List<InvestmentFund>> call({FundExchange? filter}) =>
      _repository.getFunds(filter: filter);
}
