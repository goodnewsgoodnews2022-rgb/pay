import '../repositories/admin_repository.dart';

class SendBroadcastNotification {
  final AdminRepository repository;
  SendBroadcastNotification(this.repository);

  Future<void> call(String title, String body) =>
      repository.sendBroadcastNotification(title, body);
}
