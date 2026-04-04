import 'package:equatable/equatable.dart';

enum OrderSide { buy, sell }

enum OrderType { market, limit }

enum OrderStatus { pending, filled, cancelled, rejected }

class Order extends Equatable {
  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.type,
    required this.quantity,
    required this.limitPrice,
    required this.status,
    required this.createdAt,
    this.filledPrice,
    this.filledAt,
  });

  final String id;
  final String symbol;
  final OrderSide side;
  final OrderType type;
  final double quantity;
  final double? limitPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final double? filledPrice;
  final DateTime? filledAt;

  double get estimatedTotal => quantity * (limitPrice ?? 0);

  @override
  List<Object?> get props => [id, symbol, side, type, quantity, status];
}
