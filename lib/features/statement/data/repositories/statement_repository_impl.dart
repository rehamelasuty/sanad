import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/statement_repository.dart';
import '../datasources/statement_local_datasource.dart';

class StatementRepositoryImpl implements StatementRepository {
  final StatementLocalDataSource _localDataSource;
  const StatementRepositoryImpl(this._localDataSource);

  @override
  TaskEither<Failure, List<TransactionItem>> getTransactions({
    StatementPeriod period = StatementPeriod.thisMonth,
  }) =>
      TaskEither.tryCatch(
        () async => _localDataSource.getTransactions(),
        (e, _) => UnknownFailure(e.toString()),
      );
}
