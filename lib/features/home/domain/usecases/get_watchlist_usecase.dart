import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/watchlist_item.dart';
import '../repositories/home_repository.dart';

class GetWatchlistUseCase {
  final HomeRepository _repository;

  const GetWatchlistUseCase(this._repository);

  TaskEither<Failure, List<WatchlistItem>> call() =>
      _repository.getWatchlist();
}
