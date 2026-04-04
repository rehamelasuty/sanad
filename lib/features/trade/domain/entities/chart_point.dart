import 'package:equatable/equatable.dart';

class ChartPoint extends Equatable {
  const ChartPoint({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  @override
  List<Object?> get props => [timestamp, open, high, low, close, volume];
}
