import '../entities/notification_entities.dart';
import '../repositories/notification_repository.dart';

class FetchNotifications {
  final NotificationRepository repository;
  FetchNotifications(this.repository);

  Future<List<NotificationEntity>> call({int limit = 50}) {
    return repository.fetchNotifications(limit: limit);
  }
}
