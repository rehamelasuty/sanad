import 'package:equatable/equatable.dart';

sealed class MarketsEvent extends Equatable {
  const MarketsEvent();

  @override
  List<Object?> get props => [];
}

class MarketsLoadRequested extends MarketsEvent {
  const MarketsLoadRequested();
}

class MarketsFilterChanged extends MarketsEvent {
  final String category;

  const MarketsFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class MarketsSearchChanged extends MarketsEvent {
  final String query;

  const MarketsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class MarketsRefreshRequested extends MarketsEvent {
  const MarketsRefreshRequested();
}
