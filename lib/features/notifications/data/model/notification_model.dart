import '../../domain/entities/notification_entities.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    super.data,
    required super.createdAt,
    super.isBroadcast = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final content = json['body'] ?? json['message'] ?? '';
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: content,
      type: json['type'] ?? 'system',
      isRead: json['is_read'] ?? false,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isBroadcast:
          json['user_id'] == null, // ✅ broadcast if user_id is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': message,
      'type': type,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      // note: isBroadcast is not stored in DB; it's derived from user_id
    };
  }
}
