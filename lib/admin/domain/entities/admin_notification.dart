// lib/features/admin/domain/entities/admin_notification.dart

class AdminNotification {
  final String id;
  final String title;
  final String body;
  final String? targetUserId; // null = broadcast to all
  final bool isBroadcast;
  final DateTime createdAt;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    this.targetUserId,
    required this.isBroadcast,
    required this.createdAt,
  });
}
