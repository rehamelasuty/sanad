import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ipo_listing.dart';

abstract class IpoRepository {
  TaskEither<Failure, List<IpoListing>> getIpoListings({IpoStatus? filter});
}
