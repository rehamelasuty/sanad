import 'package:equatable/equatable.dart';

class PortfolioHolding extends Equatable {
  const PortfolioHolding({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.quantity,
    required this.averageCost,
    required this.currentPrice,
    required this.isShariaCompliant,
    this.logoColor,
  });

  final String symbol;
  final String name;
  final String exchange;
  final double quantity;
  final double averageCost;
  final double currentPrice;
  final bool isShariaCompliant;
  final int? logoColor;

  double get totalCost => quantity * averageCost;
  double get marketValue => quantity * currentPrice;
  double get totalReturn => marketValue - totalCost;
  double get totalReturnPercent =>
      totalCost == 0 ? 0 : (totalReturn / totalCost) * 100;
  bool get isProfit => totalReturn >= 0;

  @override
  List<Object?> get props => [symbol, quantity, currentPrice];
}
