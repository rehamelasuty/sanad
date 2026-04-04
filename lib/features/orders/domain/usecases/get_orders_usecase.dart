import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../trade/domain/entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository _repository;
  const GetOrdersUseCase(this._repository);

  TaskEither<Failure, List<Order>> call({OrderStatus? filter}) =>
      _repository.getOrders(filter: filter);
}
