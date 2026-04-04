import 'package:equatable/equatable.dart';

import '../../domain/entities/investment_fund.dart';

abstract class FundsState extends Equatable {
  const FundsState();
  @override
  List<Object?> get props => [];
}

class FundsInitial extends FundsState {
  const FundsInitial();
}

class FundsLoading extends FundsState {
  const FundsLoading();
}

class FundsLoaded extends FundsState {
  final List<InvestmentFund> funds;
  final FundExchange? activeFilter;

  const FundsLoaded({required this.funds, this.activeFilter});

  List<InvestmentFund> get displayed => activeFilter == null
      ? funds
      : funds.where((f) => f.exchange == activeFilter).toList();

  @override
  List<Object?> get props => [funds, activeFilter];
}

class FundsError extends FundsState {
  final String message;
  const FundsError(this.message);
  @override
  List<Object?> get props => [message];
}
