import 'package:equatable/equatable.dart';

class WatchlistItem extends Equatable {
  final String symbol;
  final String name;
  final String exchange;
  final double price;
  final double change;
  final double changePercent;
  final bool isShariaCompliant;
  final String currency;
  final String sector;
  final List<double> sparklineData;

  const WatchlistItem({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isShariaCompliant,
    required this.currency,
    required this.sector,
    required this.sparklineData,
  });

  bool get isPositive => changePercent >= 0;

  @override
  List<Object?> get props => [symbol, price, changePercent];
}
