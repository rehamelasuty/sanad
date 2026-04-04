import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction_item.dart';
import '../repositories/statement_repository.dart';

class GetTransactionsUseCase {
  final StatementRepository _repository;
  const GetTransactionsUseCase(this._repository);

  TaskEither<Failure, List<TransactionItem>> call({
    StatementPeriod period = StatementPeriod.thisMonth,
  }) =>
      _repository.getTransactions(period: period);
}
