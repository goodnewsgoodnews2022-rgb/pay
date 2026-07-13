// lib/features/admin/domain/repositories/admin_repository.dart
import 'package:fintech/admin/domain/entities/admin_dashboard_stat.dart';

import '../entities/admin_user.dart';
import '../entities/admin_transaction.dart';


abstract class AdminRepository {
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<AdminUser>> getAllUsers({int limit = 50, int offset = 0});
  Future<AdminUser> getUserDetails(String userId);
  Future<void> updateUserStatus(
    String userId, {
    bool? isSuspended,
    String? suspensionReason,
  });
  Future<void> approveKyc(String userId);
  Future<void> rejectKyc(String userId, {String? reason});
  Future<List<AdminTransaction>> getTransactions({
    String? type,
    String? status,
    int limit = 50,
  });
  Future<void> sendBroadcastNotification(String title, String body);
  Future<void> sendUserNotification(
    String userId,
    String title,
    String body,
  );
}
