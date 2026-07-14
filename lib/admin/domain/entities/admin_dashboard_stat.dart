// lib/features/admin/domain/entities/admin_dashboard_stats.dart

class AdminDashboardStats {
  final int totalUsers;
  final int pendingKyc;
  final double totalDeposits;
  final double totalWithdrawals;
  final int totalTransactions;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.pendingKyc,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalTransactions, required int activeUsers, required int suspendedUsers,
  });
}
