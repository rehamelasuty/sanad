import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_asset_allocations_usecase.dart';
import '../../domain/usecases/get_holdings_usecase.dart';
import 'portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit({
    required GetHoldingsUseCase getHoldings,
    required GetAssetAllocationsUseCase getAllocations,
  })  : _getHoldings = getHoldings,
        _getAllocations = getAllocations,
        super(const PortfolioInitial());

  final GetHoldingsUseCase _getHoldings;
  final GetAssetAllocationsUseCase _getAllocations;

  Future<void> loadPortfolio() async {
    emit(const PortfolioLoading());

    final holdingsResult = await _getHoldings().run();
    final allocResult = await _getAllocations().run();

    holdingsResult.fold(
      (failure) => emit(PortfolioError(failure.userMessage)),
      (holdings) => allocResult.fold(
        (failure) => emit(PortfolioError(failure.userMessage)),
        (allocs) => emit(
          PortfolioLoaded(holdings: holdings, allocations: allocs),
        ),
      ),
    );
  }

  void toggleHideValues() {
    final current = state;
    if (current is PortfolioLoaded) {
      emit(current.copyWith(hideValues: !current.hideValues));
    }
  }

  void changeSortOrder(HoldingSortOrder order) {
    final current = state;
    if (current is PortfolioLoaded) {
      emit(current.copyWith(sortOrder: order));
    }
  }

  Future<void> refresh() => loadPortfolio();
}
