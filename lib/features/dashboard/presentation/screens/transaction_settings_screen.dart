// lib/features/more/presentation/screens/transaction_settings_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class TransactionSettingsScreen extends StatelessWidget {
  const TransactionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction Rules', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Default Wallet Asset Source'),
            trailing: const Text('Fiat Wallet (USD)', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.trending_up_rounded),
            title: const Text('Daily Transaction Velocity Limits'),
            subtitle: const Text('Set maximum allocation parameters'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Auto-save Verified Beneficiaries'),
            subtitle: const Text('Skip repeated security queries for trusted handles'),
            trailing: Switch(value: true, activeColor: theme.colorScheme.primary, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}