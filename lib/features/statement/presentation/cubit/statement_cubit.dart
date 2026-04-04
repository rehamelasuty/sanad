import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/statement_repository.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'statement_state.dart';

class StatementCubit extends Cubit<StatementState> {
  final GetTransactionsUseCase _getTransactions;

  StatementCubit({required GetTransactionsUseCase getTransactions})
      : _getTransactions = getTransactions,
        super(const StatementInitial());

  Future<void> loadTransactions({
    StatementPeriod period = StatementPeriod.thisMonth,
  }) async {
    emit(const StatementLoading());
    final result = await _getTransactions(period: period).run();
    result.fold(
      (failure) => emit(StatementError(failure.message)),
      (items) => emit(StatementLoaded(transactions: items, activePeriod: period)),
    );
  }

  void changePeriod(StatementPeriod period) {
    loadTransactions(period: period);
  }
}
