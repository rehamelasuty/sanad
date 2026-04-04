import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_orders_usecase.dart';
import '../../../trade/domain/entities/order.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase _getOrders;

  OrdersCubit({required GetOrdersUseCase getOrders})
      : _getOrders = getOrders,
        super(const OrdersInitial());

  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    final result = await _getOrders().run();
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }

  void filterByStatus(OrderStatus? status) {
    final current = state;
    if (current is OrdersLoaded) {
      emit(OrdersLoaded(orders: current.orders, activeFilter: status));
    }
  }
}
