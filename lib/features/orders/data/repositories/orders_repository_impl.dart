import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../trade/domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDataSource _localDataSource;
  const OrdersRepositoryImpl(this._localDataSource);

  @override
  TaskEither<Failure, List<Order>> getOrders({OrderStatus? filter}) =>
      TaskEither.tryCatch(
        () async {
          final orders = _localDataSource.getOrders();
          if (filter == null) return orders;
          return orders.where((o) => o.status == filter).toList();
        },
        (e, _) => UnknownFailure(e.toString()),
      );
}
