import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/get_stock_detail_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import 'trade_state.dart';

class TradeCubit extends Cubit<TradeState> {
  TradeCubit({
    required GetStockDetailUseCase getStockDetail,
    required PlaceOrderUseCase placeOrder,
  })  : _getStockDetail = getStockDetail,
        _placeOrder = placeOrder,
        super(const TradeInitial());

  final GetStockDetailUseCase _getStockDetail;
  final PlaceOrderUseCase _placeOrder;

  Future<void> loadStock(String symbol) async {
    emit(const TradeLoading());
    final result = await _getStockDetail(symbol).run();
    result.fold(
      (failure) => emit(TradeError(failure.userMessage)),
      (stock) => emit(TradeLoaded(stock: stock)),
    );
  }

  void selectChartRange(ChartRange range) {
    final current = state;
    if (current is TradeLoaded) {
      emit(current.copyWith(selectedChartRange: range));
    }
  }

  void setOrderSide(OrderSideTab side) {
    final current = state;
    if (current is TradeLoaded) {
      emit(current.copyWith(orderSide: side));
    }
  }

  void updateQuantity(double qty) {
    final current = state;
    if (current is TradeLoaded) {
      emit(current.copyWith(quantity: qty.clamp(1, 10000)));
    }
  }

  Future<void> placeOrder() async {
    final current = state;
    if (current is! TradeLoaded) return;

    emit(current.copyWith(isPlacingOrder: true, orderSuccess: false));

    final side = current.orderSide == OrderSideTab.buy
        ? OrderSide.buy
        : OrderSide.sell;

    final result = await _placeOrder(
      symbol: current.stock.symbol,
      side: side,
      type: OrderType.market,
      quantity: current.quantity,
    ).run();

    result.fold(
      (failure) => emit(current.copyWith(isPlacingOrder: false)),
      (order) => emit(current.copyWith(
        isPlacingOrder: false,
        orderSuccess: true,
        placedOrder: order,
      )),
    );
  }

  void dismissOrderSuccess() {
    final current = state;
    if (current is TradeLoaded) {
      emit(current.copyWith(orderSuccess: false, placedOrder: null));
    }
  }
}
