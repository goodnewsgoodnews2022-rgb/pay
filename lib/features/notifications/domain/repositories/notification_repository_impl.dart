import 'package:fintech/features/notifications/data/model/notification_model.dart';
import 'package:fintech/features/notifications/domain/entities/notification_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/notification_repository.dart';


class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<NotificationEntity>> fetchNotifications({
    int limit = 50,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    final List<dynamic> data = response;
    return data
        .map<NotificationEntity>(
          (json) => NotificationModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    // Use RPC – works on all versions
    final count = await _supabase.rpc(
      'get_unread_count',
      params: {'user_id_param': userId},
    );
    return count as int? ?? 0;
  }

  @override
  RealtimeChannel subscribeToNewNotifications(
    Function(Map<String, dynamic>) onInsert,
  ) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return _supabase
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['user_id'] == userId) {
              onInsert(newRecord);
            }
          },
        )
        .subscribe();
  }
}
