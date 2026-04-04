import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repository;
  const GetNotificationsUseCase(this._repository);

  TaskEither<Failure, List<AppNotification>> call() =>
      _repository.getNotifications();
}
