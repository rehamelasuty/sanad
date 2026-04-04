import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../trade/domain/entities/order.dart';

abstract class OrdersRepository {
  TaskEither<Failure, List<Order>> getOrders({OrderStatus? filter});
}
