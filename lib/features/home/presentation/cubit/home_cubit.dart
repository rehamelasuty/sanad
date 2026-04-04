import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_portfolio_summary_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetPortfolioSummaryUseCase _getPortfolioSummary;
  final GetWatchlistUseCase _getWatchlist;

  HomeCubit({
    required GetPortfolioSummaryUseCase getPortfolioSummary,
    required GetWatchlistUseCase getWatchlist,
  })  : _getPortfolioSummary = getPortfolioSummary,
        _getWatchlist = getWatchlist,
        super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());

    // Run both use-cases in parallel using fpdart TaskEither
    final summaryResult = await _getPortfolioSummary().run();
    final watchlistResult = await _getWatchlist().run();

    summaryResult.fold(
      (failure) => emit(HomeError(failure.userMessage)),
      (summary) => watchlistResult.fold(
        (failure) => emit(HomeError(failure.userMessage)),
        (watchlist) => emit(HomeLoaded(
          summary: summary,
          watchlist: watchlist,
        )),
      ),
    );
  }

  Future<void> refresh() => loadHome();
}
