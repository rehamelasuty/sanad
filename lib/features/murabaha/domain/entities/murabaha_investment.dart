import 'package:equatable/equatable.dart';

import 'murabaha_plan.dart';

enum InvestmentStatus { active, completed, cancelled }

class MurabahaInvestment extends Equatable {
  const MurabahaInvestment({
    required this.id,
    required this.plan,
    required this.principalAmount,
    required this.startDate,
    required this.maturityDate,
    required this.status,
    this.returnAmount,
  });

  final String id;
  final MurabahaPlan plan;
  final double principalAmount;
  final DateTime startDate;
  final DateTime maturityDate;
  final InvestmentStatus status;
  final double? returnAmount;

  double get expectedProfit => plan.expectedReturn(principalAmount);
  double get expectedTotal => plan.totalPayout(principalAmount);
  int get daysRemaining =>
      maturityDate.difference(DateTime.now()).inDays.clamp(0, 999);
  double get progressPercent {
    final total = maturityDate.difference(startDate).inDays;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [id, principalAmount, status];
}
