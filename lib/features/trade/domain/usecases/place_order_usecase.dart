import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/trade_repository.dart';

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final TradeRepository _repository;

  TaskEither<Failure, Order> call({
    required String symbol,
    required OrderSide side,
    required OrderType type,
    required double quantity,
    double? limitPrice,
  }) =>
      _repository.placeOrder(
        symbol: symbol,
        side: side,
        type: type,
        quantity: quantity,
        limitPrice: limitPrice,
      );
}
