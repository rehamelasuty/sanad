import '../../domain/entities/app_notification.dart';

class NotificationsLocalDataSource {
  List<AppNotification> getNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'NOTIF-001',
        title: 'تم تنفيذ الأمر',
        body: 'تم شراء 10 أسهم من AAPL بسعر \$189.50',
        type: AppNotificationType.tradeExecution,
        createdAt: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      AppNotification(
        id: 'NOTIF-002',
        title: 'عائد المرابحة',
        body: 'تم إضافة عائد شهري بقيمة SAR 1,240 لمرابحة التقنية',
        type: AppNotificationType.murabaha,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      AppNotification(
        id: 'NOTIF-003',
        title: 'تنبيه سعر',
        body: 'وصل سهم NVDA إلى المستوى المستهدف \$180',
        type: AppNotificationType.priceAlert,
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: true,
      ),
      AppNotification(
        id: 'NOTIF-004',
        title: 'إيداع ناجح',
        body: 'تم إيداع SAR 5,000 في حسابك بنجاح',
        type: AppNotificationType.deposit,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'NOTIF-005',
        title: 'تنبيه مهم',
        body: 'ينتهي التحقق من هويتك خلال 7 أيام — يرجى التجديد',
        type: AppNotificationType.warning,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'NOTIF-006',
        title: 'مرحباً بك في Sanad',
        body: 'حسابك الاستثماري جاهز — ابدأ رحلتك الاستثمارية الآن',
        type: AppNotificationType.info,
        createdAt: now.subtract(const Duration(days: 7)),
        isRead: true,
      ),
    ];
  }
}
