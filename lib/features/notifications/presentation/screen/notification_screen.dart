// lib/features/notifications/presentation/screens/notification_screen.dart

import 'package:fintech/features/notifications/domain/entities/notification_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widget/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    // Get current user admin status from AuthBloc
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState is AuthAuthenticated && authState.user.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<NotificationBloc>().add(
                MarkAllNotificationsAsRead(),
              );
            },
            icon: const Icon(Icons.done_all, color: AppColors.dev2Green),
            label: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.dev2Green),
            ),
          ),
          // ✅ "Delete all" – only shows for admin (or you can allow for users to delete personal)
          // But we'll show it for everyone – it will only delete personal notifications anyway.
          TextButton.icon(
            onPressed: () {
              _confirmDeleteAll(context);
            },
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            label: const Text(
              'Delete all',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.dev2Green),
            );
          }
          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        LoadNotifications(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dev2Green,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return NotificationTile(
                  notification: notification,
                  isAdmin: isAdmin, // ✅ pass admin status
                  onTap: () {
                    if (!notification.isRead) {
                      context.read<NotificationBloc>().add(
                        MarkNotificationAsRead(notification.id),
                      );
                    }
                    _showNotificationDialog(context, notification);
                  },
                  onDelete: () {
                    context.read<NotificationBloc>().add(
                      DeleteNotification(notification.id),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    NotificationEntity notification,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year} ${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.dev2Green),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Delete All Notifications',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will delete all your personal notifications (deposits, withdrawals, etc.). Broadcast notifications will not be deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NotificationBloc>().add(
                DeleteAllNotifications(),
              );
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
