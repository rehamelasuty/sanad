import 'package:equatable/equatable.dart';

/// Extended stock info shown on the Trade screen.
class StockDetail extends Equatable {
  const StockDetail({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.changeToday,
    required this.changeTodayPercent,
    required this.open,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.volume,
    required this.marketCap,
    required this.peRatio,
    required this.week52High,
    required this.week52Low,
    required this.isShariaCompliant,
    required this.debtToEquityRatio,
    required this.prohibitedRevenuePercent,
    required this.purificationPercent,
    required this.chartData,
    this.logoColor,
  });

  final String symbol;
  final String name;
  final String exchange;
  final double currentPrice;
  final double changeToday;
  final double changeTodayPercent;
  final double open;
  final double high;
  final double low;
  final double previousClose;
  final double volume;
  final double marketCap;
  final double peRatio;
  final double week52High;
  final double week52Low;

  // Sharia screening data
  final bool isShariaCompliant;
  final double debtToEquityRatio;
  final double prohibitedRevenuePercent;
  final double purificationPercent;

  final List<double> chartData;
  final int? logoColor;

  bool get isPositive => changeTodayPercent >= 0;

  @override
  List<Object?> get props => [symbol, currentPrice, isShariaCompliant];
}
