import 'package:equatable/equatable.dart';

import '../../domain/entities/murabaha_investment.dart';
import '../../domain/entities/murabaha_plan.dart';

sealed class MurabahaState extends Equatable {
  const MurabahaState();

  @override
  List<Object?> get props => [];
}

final class MurabahaInitial extends MurabahaState {
  const MurabahaInitial();
}

final class MurabahaLoading extends MurabahaState {
  const MurabahaLoading();
}

final class MurabahaLoaded extends MurabahaState {
  const MurabahaLoaded({
    required this.plans,
    required this.investments,
    this.selectedPlan,
    this.amount = 10000,
    this.isInvesting = false,
    this.lastInvestment,
  });

  final List<MurabahaPlan> plans;
  final List<MurabahaInvestment> investments;
  final MurabahaPlan? selectedPlan;
  final double amount;
  final bool isInvesting;
  final MurabahaInvestment? lastInvestment;

  double get expectedReturn =>
      selectedPlan?.expectedReturn(amount) ?? 0;

  double get totalPayout =>
      selectedPlan?.totalPayout(amount) ?? amount;

  MurabahaLoaded copyWith({
    List<MurabahaPlan>? plans,
    List<MurabahaInvestment>? investments,
    MurabahaPlan? selectedPlan,
    bool clearSelectedPlan = false,
    double? amount,
    bool? isInvesting,
    MurabahaInvestment? lastInvestment,
    bool clearLastInvestment = false,
  }) =>
      MurabahaLoaded(
        plans: plans ?? this.plans,
        investments: investments ?? this.investments,
        selectedPlan:
            clearSelectedPlan ? null : selectedPlan ?? this.selectedPlan,
        amount: amount ?? this.amount,
        isInvesting: isInvesting ?? this.isInvesting,
        lastInvestment:
            clearLastInvestment ? null : lastInvestment ?? this.lastInvestment,
      );

  @override
  List<Object?> get props =>
      [plans, investments, selectedPlan, amount, isInvesting, lastInvestment];
}

final class MurabahaError extends MurabahaState {
  const MurabahaError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
