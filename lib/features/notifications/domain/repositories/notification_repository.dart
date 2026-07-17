import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintech/features/notifications/domain/entities/notification_entities.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> fetchNotifications({int limit = 50});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId); // ✅ new
  Future<void> deleteAllNotifications();
  Future<int> getUnreadCount();
  RealtimeChannel subscribeToNewNotifications(
    Function(Map<String, dynamic>) onInsert,
  );
}
