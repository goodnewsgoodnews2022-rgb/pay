// lib/features/admin/presentation/screens/admin_transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_transaction_tile.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState
    extends State<AdminTransactionsScreen> {
  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    context.read<AdminBloc>().add(
      LoadTransactions(type: _selectedType, status: _selectedStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'All Transactions',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.textPrimary,
            ),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.dev1Silver,
              ),
            );
          }
          if (state is AdminTransactionsLoaded) {
            final txs = state.transactions;
            if (txs.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.builder(
              itemCount: txs.length,
              itemBuilder: (context, index) {
                return AdminTransactionTile(transaction: txs[index]);
              },
            );
          }
          return const Center(
            child: Text(
              'Failed to load transactions',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Filter Transactions',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: AppColors.bgSurface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Type',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              items: ['all', 'deposit', 'withdrawal', 'transfer']
                  .map(
                    (t) => DropdownMenuItem(
                      value: t == 'all' ? null : t,
                      child: Text(t.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              dropdownColor: AppColors.bgSurface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              items: ['all', 'pending', 'completed', 'failed']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s == 'all' ? null : s,
                      child: Text(s.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedStatus = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadTransactions();
            },
            child: const Text(
              'Apply',
              style: TextStyle(color: AppColors.dev1Silver),
            ),
          ),
        ],
      ),
    );
  }
}
