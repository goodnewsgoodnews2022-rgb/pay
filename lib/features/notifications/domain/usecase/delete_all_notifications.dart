// lib/features/notifications/domain/usecase/delete_all_notifications.dart

import '../repositories/notification_repository.dart';

class DeleteAllNotifications {
  final NotificationRepository repository;
  DeleteAllNotifications(this.repository);

  Future<void> call() {
    return repository.deleteAllNotifications();
  }
}
