import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock.dart';
import '../../domain/usecases/get_market_indices_usecase.dart';
import '../../domain/usecases/get_stocks_usecase.dart';
import 'markets_event.dart';
import 'markets_state.dart';

class MarketsBloc extends Bloc<MarketsEvent, MarketsState> {
  final GetStocksUseCase _getStocks;
  final GetMarketIndicesUseCase _getMarketIndices;

  MarketsBloc({
    required GetStocksUseCase getStocks,
    required GetMarketIndicesUseCase getMarketIndices,
  })  : _getStocks = getStocks,
        _getMarketIndices = getMarketIndices,
        super(const MarketsInitial()) {
    on<MarketsLoadRequested>((_, emit) => _onLoad(emit));
    on<MarketsRefreshRequested>((_, emit) => _onLoad(emit));
    on<MarketsFilterChanged>((e, emit) => _onFilter(e.category, emit));
    on<MarketsSearchChanged>((e, emit) => _onSearch(e.query, emit));
  }

  Future<void> _onLoad(Emitter<MarketsState> emit) async {
    emit(const MarketsLoading());

    final indicesResult = await _getMarketIndices().run();
    final stocksResult = await _getStocks().run();

    indicesResult.fold(
      (failure) => emit(MarketsError(failure.userMessage)),
      (indices) => stocksResult.fold(
        (failure) => emit(MarketsError(failure.userMessage)),
        (stocks) => emit(
          MarketsLoaded(
            indices: indices,
            allStocks: stocks,
            filteredStocks: stocks,
            activeFilter: 'all',
            searchQuery: '',
          ),
        ),
      ),
    );
  }

  Future<void> _onFilter(String category, Emitter<MarketsState> emit) async {
    final loaded = state;
    if (loaded is! MarketsLoaded) return;

    final stocksResult = await _getStocks(category: category).run();
    stocksResult.fold(
      (_) {},
      (stocks) => emit(
        loaded.copyWith(
          filteredStocks: _applySearch(stocks, loaded.searchQuery),
          allStocks: stocks,
          activeFilter: category,
        ),
      ),
    );
  }

  void _onSearch(String query, Emitter<MarketsState> emit) {
    final loaded = state;
    if (loaded is! MarketsLoaded) return;

    final filtered = _applySearch(loaded.allStocks, query);
    emit(loaded.copyWith(filteredStocks: filtered, searchQuery: query));
  }

  List<Stock> _applySearch(List<Stock> stocks, String query) {
    if (query.isEmpty) return stocks;
    final q = query.toLowerCase();
    return stocks
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .toList();
  }
}
