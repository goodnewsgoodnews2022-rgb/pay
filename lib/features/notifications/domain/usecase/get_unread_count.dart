import '../repositories/notification_repository.dart';

class GetUnreadCount {
  final NotificationRepository repository;
  GetUnreadCount(this.repository);

  Future<int> call() {
    return repository.getUnreadCount();
  }
}
