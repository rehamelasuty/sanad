import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction_item.dart';

enum StatementPeriod { thisMonth, lastMonth, threeMonths, year }

abstract class StatementRepository {
  TaskEither<Failure, List<TransactionItem>> getTransactions({
    StatementPeriod period,
  });
}
