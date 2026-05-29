import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/notification_repository.dart';

class SubscribeToNotifications {
  final NotificationRepository repository;
  SubscribeToNotifications(this.repository);

  RealtimeChannel call(Function(Map<String, dynamic>) onInsert) {
    return repository.subscribeToNewNotifications(onInsert);
  }
}
