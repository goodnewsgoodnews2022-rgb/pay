abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationAsRead(this.notificationId);
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class NewNotificationReceived extends NotificationEvent {
  final Map<String, dynamic> notificationData;
  NewNotificationReceived(this.notificationData);
}
