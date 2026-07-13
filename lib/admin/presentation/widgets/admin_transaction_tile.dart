// lib/features/admin/presentation/widgets/admin_transaction_tile.dart

import 'package:fintech/admin/domain/entities/admin_transaction.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class AdminTransactionTile extends StatelessWidget {
  final AdminTransaction transaction;

  const AdminTransactionTile({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'deposit';
    final isCompleted = transaction.status == 'completed';

    return Card(
      color: AppColors.bgSurface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDeposit
              ? AppColors.dev2Green.withOpacity(0.2)
              : AppColors.error.withOpacity(0.2),
          child: Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isDeposit ? AppColors.dev2Green : AppColors.error,
          ),
        ),
        title: Text(
          '${transaction.userEmail}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${transaction.type.toUpperCase()} • ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isDeposit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
              style: TextStyle(
                color: isDeposit ? AppColors.dev2Green : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              transaction.status.toUpperCase(),
              style: TextStyle(
                color: isCompleted ? AppColors.dev2Green : Colors.orange,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
