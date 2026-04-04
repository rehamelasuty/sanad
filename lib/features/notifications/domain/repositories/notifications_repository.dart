import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  TaskEither<Failure, List<AppNotification>> getNotifications();
  TaskEither<Failure, Unit> markAllRead();
}
