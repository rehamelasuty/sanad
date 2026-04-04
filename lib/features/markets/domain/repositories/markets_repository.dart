import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/market_index.dart';
import '../entities/stock.dart';

abstract interface class MarketsRepository {
  TaskEither<Failure, List<Stock>> getStocks({String? category});
  TaskEither<Failure, List<MarketIndex>> getMarketIndices();
}
