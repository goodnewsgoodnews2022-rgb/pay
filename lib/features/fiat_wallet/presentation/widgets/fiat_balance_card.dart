import 'package:fintech/features/fiat_wallet/domain/entities/fiat_account.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';


class FiatBalanceCard extends StatelessWidget {
  final FiatAccount account;
  const FiatBalanceCard({required this.account, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.bgSurface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.dev2Green.withOpacity(0.2),
          child: Text(
            account.currency[0],
            style: const TextStyle(color: AppColors.dev2Green),
          ),
        ),
        title: Text(
          '${account.currency} Wallet',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: account.accountNumber != null
            ? Text(
                'Account: ${account.accountNumber}',
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : null,
        trailing: Text(
          '${account.balance.toStringAsFixed(2)} ${account.currency}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onTap: () => context.push('/fiat-transactions/${account.id}'),
      ),
    );
  }
}
