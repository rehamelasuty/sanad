import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/asset_allocation.dart';
import '../entities/portfolio_holding.dart';

abstract interface class PortfolioRepository {
  TaskEither<Failure, List<PortfolioHolding>> getHoldings();

  TaskEither<Failure, List<AssetAllocation>> getAssetAllocations();
}
