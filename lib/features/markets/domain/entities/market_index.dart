import 'package:equatable/equatable.dart';

class MarketIndex extends Equatable {
  final String name;
  final double value;
  final double changePercent;

  const MarketIndex({
    required this.name,
    required this.value,
    required this.changePercent,
  });

  bool get isPositive => changePercent >= 0;

  @override
  List<Object?> get props => [name, value, changePercent];
}
