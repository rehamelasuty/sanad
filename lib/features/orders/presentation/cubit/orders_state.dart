import 'package:equatable/equatable.dart';

import '../../../trade/domain/entities/order.dart';

export '../../../trade/domain/entities/order.dart' show Order, OrderStatus, OrderSide, OrderType;

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final OrderStatus? activeFilter;

  const OrdersLoaded({required this.orders, this.activeFilter});

  List<Order> get displayed => activeFilter == null
      ? orders
      : orders.where((o) => o.status == activeFilter).toList();

  @override
  List<Object?> get props => [orders, activeFilter];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override
  List<Object?> get props => [message];
}
