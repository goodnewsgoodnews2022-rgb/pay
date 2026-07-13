// lib/features/admin/presentation/widgets/admin_user_tile.dart

import 'package:fintech/admin/domain/entities/admin_user.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class AdminUserTile extends StatelessWidget {
  final AdminUser user;
  final VoidCallback? onTap;
  final bool showKycActions;
  final VoidCallback? onSuspendToggle;
  final VoidCallback? onApproveKyc;
  final VoidCallback? onRejectKyc;

  const AdminUserTile({
    required this.user,
    this.onTap,
    this.showKycActions = false,
    this.onSuspendToggle,
    this.onApproveKyc,
    this.onRejectKyc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.bgSurface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: user.isAdmin
              ? AppColors.dev1Silver
              : Colors.grey.shade600,
          child: Text(
            user.fullName?.isNotEmpty == true
                ? user.fullName![0].toUpperCase()
                : 'U',
            style: TextStyle(
              color: user.isAdmin ? Colors.black : Colors.white,
            ),
          ),
        ),
        title: Text(
          user.fullName ?? user.email,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(
                  'KYC: ${user.kycStatus}',
                  _getKycColor(user.kycStatus),
                ),
                const SizedBox(width: 8),
                if (user.isSuspended)
                  _buildStatusChip('SUSPENDED', AppColors.error),
              ],
            ),
          ],
        ),
        trailing: showKycActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: AppColors.dev2Green,
                    ),
                    onPressed: onApproveKyc,
                    tooltip: 'Approve KYC',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    onPressed: onRejectKyc,
                    tooltip: 'Reject KYC',
                  ),
                ],
              )
            : IconButton(
                icon: Icon(
                  user.isSuspended ? Icons.block : Icons.block_flipped,
                  color: user.isSuspended
                      ? AppColors.error
                      : AppColors.dev2Green,
                ),
                onPressed: onSuspendToggle,
                tooltip: user.isSuspended ? 'Unsuspend' : 'Suspend',
              ),
      ),
    );
  }

  Color _getKycColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.dev2Green;
      case 'REJECTED':
        return AppColors.error;
      default:
        return Colors.orange;
    }
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
