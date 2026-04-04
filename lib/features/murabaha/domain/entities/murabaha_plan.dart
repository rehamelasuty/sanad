import 'package:equatable/equatable.dart';

/// Murabaha investment plan type.
enum MurabahaPlanType {
  weekly,
  monthly,
  quarterly;

  String get label => switch (this) {
        MurabahaPlanType.weekly => 'أسبوعي',
        MurabahaPlanType.monthly => 'شهري',
        MurabahaPlanType.quarterly => 'ربع سنوي',
      };
}

class MurabahaPlan extends Equatable {
  const MurabahaPlan({
    required this.id,
    required this.type,
    required this.annualRatePercent,
    required this.minAmount,
    required this.maxAmount,
    required this.termDays,
    required this.description,
    required this.isActive,
  });

  final String id;
  final MurabahaPlanType type;
  final double annualRatePercent;
  final double minAmount;
  final double maxAmount;
  final int termDays;
  final String description;
  final bool isActive;

  /// Calculate expected return for [amount] at end of term.
  double expectedReturn(double amount) =>
      amount * (annualRatePercent / 100) * (termDays / 365);

  /// Total payout (principal + profit).
  double totalPayout(double amount) => amount + expectedReturn(amount);

  @override
  List<Object?> get props => [id, type, annualRatePercent];
}
