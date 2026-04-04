import 'package:equatable/equatable.dart';
import '../../domain/entities/market_index.dart';
import '../../domain/entities/stock.dart';

sealed class MarketsState extends Equatable {
  const MarketsState();

  @override
  List<Object?> get props => [];
}

class MarketsInitial extends MarketsState {
  const MarketsInitial();
}

class MarketsLoading extends MarketsState {
  const MarketsLoading();
}

class MarketsLoaded extends MarketsState {
  final List<MarketIndex> indices;
  final List<Stock> allStocks;
  final List<Stock> filteredStocks;
  final String activeFilter;
  final String searchQuery;

  const MarketsLoaded({
    required this.indices,
    required this.allStocks,
    required this.filteredStocks,
    required this.activeFilter,
    required this.searchQuery,
  });

  MarketsLoaded copyWith({
    List<MarketIndex>? indices,
    List<Stock>? allStocks,
    List<Stock>? filteredStocks,
    String? activeFilter,
    String? searchQuery,
  }) =>
      MarketsLoaded(
        indices: indices ?? this.indices,
        allStocks: allStocks ?? this.allStocks,
        filteredStocks: filteredStocks ?? this.filteredStocks,
        activeFilter: activeFilter ?? this.activeFilter,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props =>
      [indices, filteredStocks, activeFilter, searchQuery];
}

class MarketsError extends MarketsState {
  final String message;

  const MarketsError(this.message);

  @override
  List<Object?> get props => [message];
}
