import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/investment_fund.dart';

abstract class FundsRepository {
  TaskEither<Failure, List<InvestmentFund>> getFunds({FundExchange? filter});
}
