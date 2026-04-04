import 'package:equatable/equatable.dart';

enum AppNotificationType {
  tradeExecution,
  murabaha,
  priceAlert,
  deposit,
  warning,
  info,
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;
  final bool isRead;

  String get iconEmoji {
    switch (type) {
      case AppNotificationType.tradeExecution:
        return '📈';
      case AppNotificationType.murabaha:
        return '💰';
      case AppNotificationType.priceAlert:
        return '🔔';
      case AppNotificationType.deposit:
        return '💳';
      case AppNotificationType.warning:
        return '⚠️';
      case AppNotificationType.info:
        return 'ℹ️';
    }
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props => [id, title, body, type, createdAt, isRead];
}
