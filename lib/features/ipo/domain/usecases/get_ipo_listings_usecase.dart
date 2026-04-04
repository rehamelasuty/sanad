import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ipo_listing.dart';
import '../repositories/ipo_repository.dart';

class GetIpoListingsUseCase {
  final IpoRepository _repository;
  const GetIpoListingsUseCase(this._repository);

  TaskEither<Failure, List<IpoListing>> call({IpoStatus? filter}) =>
      _repository.getIpoListings(filter: filter);
}
