import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ipo_listing.dart';
import '../../domain/repositories/ipo_repository.dart';
import '../datasources/ipo_local_datasource.dart';

class IpoRepositoryImpl implements IpoRepository {
  final IpoLocalDataSource _localDataSource;
  const IpoRepositoryImpl(this._localDataSource);

  @override
  TaskEither<Failure, List<IpoListing>> getIpoListings({IpoStatus? filter}) =>
      TaskEither.tryCatch(
        () async {
          final listings = _localDataSource.getIpoListings();
          if (filter == null) return listings;
          return listings.where((l) => l.status == filter).toList();
        },
        (e, _) => UnknownFailure(e.toString()),
      );
}
