import 'package:fintech/features/notifications/data/model/notification_model.dart';
import 'package:fintech/features/notifications/domain/usecase/fetch_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/features/notifications/domain/usecase/get_unread_count.dart';
import 'package:fintech/features/notifications/domain/usecase/mark_all_as_read.dart';   
import 'package:fintech/features/notifications/domain/usecase/mark_as_read.dart';
import 'package:fintech/features/notifications/domain/usecase/subscribe_to_notification.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FetchNotifications fetchNotifications;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;
  final GetUnreadCount getUnreadCount;
  final SubscribeToNotifications subscribeToNotifications;

  NotificationBloc({
    required this.fetchNotifications,
    required this.markAsRead,
    required this.markAllAsRead,
    required this.getUnreadCount,
    required this.subscribeToNotifications,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<NewNotificationReceived>(_onNewNotificationReceived);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await fetchNotifications();
      final unreadCount = await getUnreadCount();
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markAsRead(event.notificationId);
      // Reload after marking as read
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markAllAsRead();
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onNewNotificationReceived(
    NewNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // Prepend new notification and update unread count
      final newNotification = NotificationModel.fromJson(
        event.notificationData,
      );
      final updatedList = [newNotification, ...currentState.notifications];
      emit(
        NotificationLoaded(
          notifications: updatedList,
          unreadCount: currentState.unreadCount + 1,
        ),
      );
    } else {
      // If not on notifications screen, just reload when opened
      add(LoadNotifications());
    }
  }
}
