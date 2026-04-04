import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/stock_detail.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/trade_local_datasource.dart';

class TradeRepositoryImpl implements TradeRepository {
  const TradeRepositoryImpl(this._localDataSource);

  final TradeLocalDataSource _localDataSource;

  @override
  TaskEither<Failure, StockDetail> getStockDetail(String symbol) =>
      TaskEither.tryCatch(
        () => _localDataSource.getStockDetail(symbol),
        _mapException,
      );

  @override
  TaskEither<Failure, Order> placeOrder({
    required String symbol,
    required OrderSide side,
    required OrderType type,
    required double quantity,
    double? limitPrice,
  }) =>
      TaskEither.tryCatch(
        () => _localDataSource.placeOrder(
          symbol: symbol,
          side: side,
          type: type,
          quantity: quantity,
          limitPrice: limitPrice,
        ),
        _mapException,
      );

  @override
  TaskEither<Failure, List<Order>> getOrderHistory(String symbol) =>
      TaskEither.tryCatch(
        () => _localDataSource.getOrderHistory(symbol),
        _mapException,
      );

  Failure _mapException(Object error, StackTrace _) {
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is ServerException) return ServerFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);
    return UnknownFailure(error.toString());
  }
}
