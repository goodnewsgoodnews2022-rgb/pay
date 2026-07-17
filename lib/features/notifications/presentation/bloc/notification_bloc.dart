// lib/features/notifications/presentation/bloc/notification_bloc.dart

import 'package:fintech/features/notifications/data/model/notification_model.dart';
import 'package:fintech/features/notifications/domain/usecase/fetch_notification.dart';
import 'package:fintech/features/notifications/domain/usecase/get_unread_count.dart';
import 'package:fintech/features/notifications/domain/usecase/mark_all_as_read.dart';
import 'package:fintech/features/notifications/domain/usecase/mark_as_read.dart';
import 'package:fintech/features/notifications/domain/usecase/subscribe_to_notification.dart';
import 'package:fintech/features/notifications/domain/usecase/delete_notification.dart' as delete_notification_usecase;
import 'package:fintech/features/notifications/domain/usecase/delete_all_notifications.dart' as delete_all_usecase;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FetchNotifications fetchNotifications;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;
  final GetUnreadCount getUnreadCount;
  final SubscribeToNotifications subscribeToNotifications;
  final delete_notification_usecase.DeleteNotification deleteNotification;
  final delete_all_usecase.DeleteAllNotifications deleteAllNotifications;

  NotificationBloc({
    required this.fetchNotifications,
    required this.markAsRead,
    required this.markAllAsRead,
    required this.getUnreadCount,
    required this.subscribeToNotifications,
    required this.deleteNotification,
    required this.deleteAllNotifications,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<NewNotificationReceived>(_onNewNotificationReceived);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
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
      add(LoadNotifications());
    }
  }

  // ✅ Fixed: call deleteNotification with the notification ID
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await deleteNotification(event.notificationId);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  // ✅ Fixed: call deleteAllNotifications with no parameters
  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await deleteAllNotifications();
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
