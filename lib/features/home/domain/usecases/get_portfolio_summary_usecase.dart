import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/portfolio_summary.dart';
import '../repositories/home_repository.dart';

class GetPortfolioSummaryUseCase {
  final HomeRepository _repository;

  const GetPortfolioSummaryUseCase(this._repository);

  TaskEither<Failure, PortfolioSummary> call() =>
      _repository.getPortfolioSummary();
}
