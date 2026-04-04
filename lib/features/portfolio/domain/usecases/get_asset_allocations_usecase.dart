import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/asset_allocation.dart';
import '../repositories/portfolio_repository.dart';

class GetAssetAllocationsUseCase {
  const GetAssetAllocationsUseCase(this._repository);

  final PortfolioRepository _repository;

  TaskEither<Failure, List<AssetAllocation>> call() =>
      _repository.getAssetAllocations();
}
