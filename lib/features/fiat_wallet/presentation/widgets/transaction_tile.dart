import 'package:fintech/features/fiat_wallet/domain/entities/fiat_transaction.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class TransactionTile extends StatelessWidget {
  final FiatTransaction transaction;
  const TransactionTile({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'deposit';
    return ListTile(
      leading: Icon(
        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
        color: isDeposit ? AppColors.success : AppColors.error,
      ),
      title: Text(
        '${isDeposit ? 'Deposit' : 'Withdrawal'} - ${transaction.reference}',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        transaction.status,
        style: TextStyle(
          color: transaction.status == 'completed'
              ? AppColors.success
              : AppColors.textSecondary,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isDeposit ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDeposit ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _formatDate(transaction.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
