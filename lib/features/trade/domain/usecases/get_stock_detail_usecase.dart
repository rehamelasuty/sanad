import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_detail.dart';
import '../repositories/trade_repository.dart';

class GetStockDetailUseCase {
  const GetStockDetailUseCase(this._repository);

  final TradeRepository _repository;

  TaskEither<Failure, StockDetail> call(String symbol) =>
      _repository.getStockDetail(symbol);
}
