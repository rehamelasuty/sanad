import 'package:equatable/equatable.dart';

import '../../domain/entities/ipo_listing.dart';

abstract class IpoState extends Equatable {
  const IpoState();
  @override
  List<Object?> get props => [];
}

class IpoInitial extends IpoState {
  const IpoInitial();
}

class IpoLoading extends IpoState {
  const IpoLoading();
}

class IpoLoaded extends IpoState {
  final List<IpoListing> listings;
  final IpoStatus? activeFilter;

  const IpoLoaded({required this.listings, this.activeFilter});

  List<IpoListing> get displayed => activeFilter == null
      ? listings
      : listings.where((l) => l.status == activeFilter).toList();

  @override
  List<Object?> get props => [listings, activeFilter];
}

class IpoError extends IpoState {
  final String message;
  const IpoError(this.message);
  @override
  List<Object?> get props => [message];
}
