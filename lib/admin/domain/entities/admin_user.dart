// lib/features/admin/domain/entities/admin_user.dart

class AdminUser {
  final String id;
  final String email;
  final String? fullName;
  final String? mobileNumber;
  final String kycStatus; // PENDING, APPROVED, REJECTED
  final bool isAdmin;
  final bool isSuspended;
  final String? suspensionReason;
  final double totalDeposits;
  final double totalWithdrawals;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    this.fullName,
    this.mobileNumber,
    required this.kycStatus,
    required this.isAdmin,
    required this.isSuspended,
    this.suspensionReason,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.createdAt,
  });
}
