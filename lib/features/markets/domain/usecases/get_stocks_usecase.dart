import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock.dart';
import '../repositories/markets_repository.dart';

class GetStocksUseCase {
  final MarketsRepository _repository;

  const GetStocksUseCase(this._repository);

  TaskEither<Failure, List<Stock>> call({String? category}) =>
      _repository.getStocks(category: category);
}
