import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/investment_fund.dart';
import '../../domain/repositories/funds_repository.dart';
import '../datasources/funds_local_datasource.dart';

class FundsRepositoryImpl implements FundsRepository {
  final FundsLocalDataSource _localDataSource;
  const FundsRepositoryImpl(this._localDataSource);

  @override
  TaskEither<Failure, List<InvestmentFund>> getFunds({FundExchange? filter}) =>
      TaskEither.tryCatch(
        () async {
          final funds = _localDataSource.getFunds();
          if (filter == null) return funds;
          return funds.where((f) => f.exchange == filter).toList();
        },
        (e, _) => UnknownFailure(e.toString()),
      );
}
