import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsLocalDataSource _localDataSource;
  const NotificationsRepositoryImpl(this._localDataSource);

  @override
  TaskEither<Failure, List<AppNotification>> getNotifications() =>
      TaskEither.tryCatch(
        () async => _localDataSource.getNotifications(),
        (e, _) => UnknownFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> markAllRead() =>
      TaskEither.tryCatch(
        () async => unit,
        (e, _) => UnknownFailure(e.toString()),
      );
}
