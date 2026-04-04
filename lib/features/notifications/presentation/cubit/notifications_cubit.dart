import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotifications;

  NotificationsCubit({required GetNotificationsUseCase getNotifications})
      : _getNotifications = getNotifications,
        super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    final result = await _getNotifications().run();
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (items) => emit(NotificationsLoaded(items)),
    );
  }

  void markAllRead() {
    final current = state;
    if (current is NotificationsLoaded) {
      final updated = current.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(NotificationsLoaded(updated));
    }
  }
}
