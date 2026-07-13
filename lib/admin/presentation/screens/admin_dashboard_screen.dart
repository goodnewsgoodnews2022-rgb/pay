// lib/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:fintech/admin/presentation/widgets/admin_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch the load event after the frame is built,
    // and only if the bloc is still open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<AdminBloc>();
        if (!bloc.isClosed) {
          bloc.add(LoadDashboardStats());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
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
          if (state is AdminDashboardLoaded) {
            final stats = state.stats;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminStatsCard(
                          title: 'Total Users',
                          value: stats.totalUsers.toString(),
                          icon: Icons.people,
                          color: AppColors.dev1Silver,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AdminStatsCard(
                          title: 'Pending KYC',
                          value: stats.pendingKyc.toString(),
                          icon: Icons.verified_user,
                          color: AppColors.dev2Green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AdminStatsCard(
                          title: 'Total Deposits',
                          value:
                              '\$${stats.totalDeposits.toStringAsFixed(2)}',
                          icon: Icons.arrow_downward,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AdminStatsCard(
                          title: 'Total Withdrawals',
                          value:
                              '\$${stats.totalWithdrawals.toStringAsFixed(2)}',
                          icon: Icons.arrow_upward,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AdminStatsCard(
                    title: 'Total Transactions',
                    value: stats.totalTransactions.toString(),
                    icon: Icons.receipt,
                    color: AppColors.dev3Purple,
                  ),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            );
          }
          // Fallback for initial or error state
          return const Center(
            child: Text(
              'Failed to load dashboard',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                context,
                'Users',
                Icons.people,
                () => context.push('/admin/users'),
              ),
              _buildActionButton(
                context,
                'KYC Review',
                Icons.verified_user,
                () => context.push('/admin/kyc'),
              ),
              _buildActionButton(
                context,
                'Transactions',
                Icons.receipt,
                () => context.push('/admin/transactions'),
              ),
              _buildActionButton(
                context,
                'Broadcast',
                Icons.notifications,
                () => context.push('/admin-broadcast'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dev1Silver,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
