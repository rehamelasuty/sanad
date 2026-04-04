import 'package:equatable/equatable.dart';

enum DcaFrequency {
  daily,    // يومي
  weekly,   // أسبوعي
  monthly,  // شهري
}

extension DcaFrequencyLabel on DcaFrequency {
  String get label => switch (this) {
        DcaFrequency.daily => 'يومي',
        DcaFrequency.weekly => 'أسبوعي',
        DcaFrequency.monthly => 'شهري',
      };
}

class DcaPlan extends Equatable {
  const DcaPlan({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.amountPerCycle,
    required this.frequency,
    required this.isActive,
    required this.createdAt,
    this.nextRunAt,
    this.totalCycles = 0,
    this.totalInvested = 0,
  });

  final String id;
  final String symbol;
  final String stockName;
  final double amountPerCycle;  // SAR
  final DcaFrequency frequency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? nextRunAt;
  final int totalCycles;
  final double totalInvested;

  double get estimatedMonthly => switch (frequency) {
        DcaFrequency.daily => amountPerCycle * 30,
        DcaFrequency.weekly => amountPerCycle * 4,
        DcaFrequency.monthly => amountPerCycle,
      };

  DcaPlan copyWith({
    bool? isActive,
    double? amountPerCycle,
    DcaFrequency? frequency,
  }) =>
      DcaPlan(
        id: id,
        symbol: symbol,
        stockName: stockName,
        amountPerCycle: amountPerCycle ?? this.amountPerCycle,
        frequency: frequency ?? this.frequency,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        nextRunAt: nextRunAt,
        totalCycles: totalCycles,
        totalInvested: totalInvested,
      );

  @override
  List<Object?> get props => [id, symbol, amountPerCycle, frequency, isActive];
}
