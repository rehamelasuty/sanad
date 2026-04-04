import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/statement_repository.dart';

abstract class StatementState extends Equatable {
  const StatementState();
  @override
  List<Object?> get props => [];
}

class StatementInitial extends StatementState {
  const StatementInitial();
}

class StatementLoading extends StatementState {
  const StatementLoading();
}

class StatementLoaded extends StatementState {
  final List<TransactionItem> transactions;
  final StatementPeriod activePeriod;

  const StatementLoaded({
    required this.transactions,
    this.activePeriod = StatementPeriod.thisMonth,
  });

  double get totalCredit =>
      transactions.where((t) => t.isCredit).fold(0, (sum, t) => sum + t.amount);
  double get totalDebit =>
      transactions.where((t) => !t.isCredit).fold(0, (sum, t) => sum + t.amount);

  @override
  List<Object?> get props => [transactions, activePeriod];
}

class StatementError extends StatementState {
  final String message;
  const StatementError(this.message);
  @override
  List<Object?> get props => [message];
}
