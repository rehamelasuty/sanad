import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/investment_fund.dart';
import '../../domain/usecases/get_funds_usecase.dart';
import 'funds_state.dart';

class FundsCubit extends Cubit<FundsState> {
  final GetFundsUseCase _getFunds;

  FundsCubit({required GetFundsUseCase getFunds})
      : _getFunds = getFunds,
        super(const FundsInitial());

  Future<void> loadFunds() async {
    emit(const FundsLoading());
    final result = await _getFunds().run();
    result.fold(
      (failure) => emit(FundsError(failure.message)),
      (items) => emit(FundsLoaded(funds: items)),
    );
  }

  void filterByExchange(FundExchange? exchange) {
    final current = state;
    if (current is FundsLoaded) {
      emit(FundsLoaded(funds: current.funds, activeFilter: exchange));
    }
  }
}
