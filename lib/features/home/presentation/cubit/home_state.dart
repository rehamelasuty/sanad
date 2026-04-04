import 'package:equatable/equatable.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/watchlist_item.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final PortfolioSummary summary;
  final List<WatchlistItem> watchlist;

  const HomeLoaded({
    required this.summary,
    required this.watchlist,
  });

  @override
  List<Object?> get props => [summary, watchlist];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
