// lib/features/admin/data/models/admin_user_model.dart

import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.mobileNumber,
    required super.kycStatus,
    required super.isAdmin,
    required super.isSuspended,
    super.suspensionReason,
    required super.totalDeposits,
    required super.totalWithdrawals,
    required super.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      email: json['email'] ?? 'no-email',
      fullName: json['full_name'],
      mobileNumber: json['mobile_number'],
      kycStatus: json['kyc_status'] ?? 'PENDING',
      isAdmin: json['is_admin'] ?? false,
      isSuspended: json['is_suspended'] ?? false,
      suspensionReason: json['suspension_reason'],
      totalDeposits: (json['total_deposits'] as num?)?.toDouble() ?? 0,
      totalWithdrawals:
          (json['total_withdrawals'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'kyc_status': kycStatus,
      'is_admin': isAdmin,
      'is_suspended': isSuspended,
      'suspension_reason': suspensionReason,
      'total_deposits': totalDeposits,
      'total_withdrawals': totalWithdrawals,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
