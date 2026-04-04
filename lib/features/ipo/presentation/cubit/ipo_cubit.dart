import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ipo_listing.dart';
import '../../domain/usecases/get_ipo_listings_usecase.dart';
import 'ipo_state.dart';

class IpoCubit extends Cubit<IpoState> {
  final GetIpoListingsUseCase _getIpoListings;

  IpoCubit({required GetIpoListingsUseCase getIpoListings})
      : _getIpoListings = getIpoListings,
        super(const IpoInitial());

  Future<void> loadListings() async {
    emit(const IpoLoading());
    final result = await _getIpoListings().run();
    result.fold(
      (failure) => emit(IpoError(failure.message)),
      (items) => emit(IpoLoaded(listings: items)),
    );
  }

  void filterByStatus(IpoStatus? status) {
    final current = state;
    if (current is IpoLoaded) {
      emit(IpoLoaded(listings: current.listings, activeFilter: status));
    }
  }
}
