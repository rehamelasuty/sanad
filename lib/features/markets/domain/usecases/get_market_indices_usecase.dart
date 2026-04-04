import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/market_index.dart';
import '../repositories/markets_repository.dart';

class GetMarketIndicesUseCase {
  final MarketsRepository _repository;

  const GetMarketIndicesUseCase(this._repository);

  TaskEither<Failure, List<MarketIndex>> call() =>
      _repository.getMarketIndices();
}
