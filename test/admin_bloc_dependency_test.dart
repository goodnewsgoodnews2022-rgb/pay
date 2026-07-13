import 'package:fintech/admin/domain/entities/admin_dashboard_stat.dart';
import 'package:fintech/admin/domain/entities/admin_transaction.dart';
import 'package:fintech/admin/domain/entities/admin_user.dart';
import 'package:fintech/admin/domain/repositories/admin_repository.dart';
import 'package:fintech/admin/domain/usecases/approve_kyc.dart';
import 'package:fintech/admin/domain/usecases/get_all_user.dart';
import 'package:fintech/admin/domain/usecases/get_dashboard_stats.dart';
import 'package:fintech/admin/domain/usecases/get_transaction.dart';
import 'package:fintech/admin/domain/usecases/reject_kyc.dart';
import 'package:fintech/admin/domain/usecases/send_broadcast_notification.dart';
import 'package:fintech/admin/domain/usecases/update_user_status.dart'
    as update_user_status;
import 'package:fintech/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminRepository implements AdminRepository {
  @override
  Future<void> approveKyc(String userId) async {}

  @override
  Future<AdminDashboardStats> getDashboardStats() async =>
      AdminDashboardStats(
        totalUsers: 0,
        activeUsers: 0,
        suspendedUsers: 0,
      );

  @override
  Future<List<AdminUser>> getAllUsers({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<AdminUser> getUserDetails(String userId) async =>
      AdminUser(id: userId, email: '', createdAt: DateTime.now());

  @override
  Future<List<AdminTransaction>> getTransactions({
    String? type,
    String? status,
    int limit = 50,
  }) async => [];

  @override
  Future<void> rejectKyc(String userId, {String? reason}) async {}

  @override
  Future<void> sendBroadcastNotification(
    String title,
    String body,
  ) async {}

  @override
  Future<void> sendUserNotification(
    String userId,
    String title,
    String body,
  ) async {}

  @override
  Future<void> updateUserStatus(
    String userId, {
    bool? isSuspended,
    String? suspensionReason,
  }) async {}
}

void main() {
  test('AdminBloc accepts the update-user-status use case', () {
    final repository = _FakeAdminRepository();

    final bloc = AdminBloc(
      getDashboardStats: GetDashboardStats(repository),
      getAllUsers: GetAllUsers(repository),
      updateUserStatus: update_user_status.UpdateUserStatus(repository),
      approveKyc: ApproveKyc(repository),
      rejectKyc: RejectKyc(repository),
      getTransactions: GetTransactions(repository),
      sendBroadcastNotification: SendBroadcastNotification(repository),
    );

    expect(bloc, isA<AdminBloc>());
  });
}
