import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../entities/stock_detail.dart';

abstract interface class TradeRepository {
  TaskEither<Failure, StockDetail> getStockDetail(String symbol);

  TaskEither<Failure, Order> placeOrder({
    required String symbol,
    required OrderSide side,
    required OrderType type,
    required double quantity,
    double? limitPrice,
  });

  TaskEither<Failure, List<Order>> getOrderHistory(String symbol);
}
