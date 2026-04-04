import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/portfolio_holding.dart';
import '../repositories/portfolio_repository.dart';

class GetHoldingsUseCase {
  const GetHoldingsUseCase(this._repository);

  final PortfolioRepository _repository;

  TaskEither<Failure, List<PortfolioHolding>> call() =>
      _repository.getHoldings();
}
