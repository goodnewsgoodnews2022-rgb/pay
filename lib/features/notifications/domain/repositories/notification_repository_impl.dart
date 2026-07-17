import 'package:fintech/features/notifications/data/model/notification_model.dart';
import 'package:fintech/features/notifications/domain/entities/notification_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/notification_repository.dart';


class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

 
  @override
@override
  Future<List<NotificationEntity>> fetchNotifications({
    int limit = 50,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('notifications')
        .select()
        .or('user_id.eq.$userId,user_id.is.null')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map<NotificationEntity>(
          (json) => NotificationModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    print(
      '📖 markAsRead - userId: $userId, notificationId: $notificationId',
    );

    final response = await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', userId)
        .select(); // ✅ this returns the updated row

    print('📖 markAsRead - update response: $response');
  }
  @override
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // ✅ Update both personal and broadcast notifications
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .or('user_id.eq.$userId,user_id.is.null');
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


  // Better to implement as:
@override
  Future<void> deleteNotification(String notificationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    print(
      '🔍 deleteNotification called by userId: $userId, notificationId: $notificationId',
    );

    // Check if user is admin
    final profile = await _supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', userId)
        .single();
    final isAdmin = profile['is_admin'] ?? false;

    print('🔍 isAdmin: $isAdmin');
    // Get notification details
    final notification = await _supabase
        .from('notifications')
        .select('user_id')
        .eq('id', notificationId)
        .maybeSingle();

    if (notification == null) throw Exception('Notification not found');
    final isBroadcast = notification['user_id'] == null;

    // Allow deletion if: personal notification OR admin
    if (!isBroadcast || isAdmin) {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } else {
      throw Exception('Only admins can delete broadcast notifications');
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Delete only personal notifications (user_id is not null)
    await _supabase.from('notifications').delete().eq('user_id', userId);
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
