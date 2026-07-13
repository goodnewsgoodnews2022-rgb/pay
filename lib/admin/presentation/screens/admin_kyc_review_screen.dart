// lib/features/admin/presentation/screens/admin_kyc_review_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_user_tile.dart';

class AdminKycReviewScreen extends StatelessWidget {
  const AdminKycReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'KYC Review',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => context.read<AdminBloc>().add(
              LoadAllUsers(limit: 100, offset: 0),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // Refresh list after action
            context.read<AdminBloc>().add(
              LoadAllUsers(limit: 100, offset: 0),
            );
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
          if (state is AdminUsersLoaded) {
            final pendingUsers = state.users
                .where((u) => u.kycStatus == 'PENDING')
                .toList();
            if (pendingUsers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppColors.dev2Green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No pending KYC submissions',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return AdminUserTile(
                  user: user,
                  showKycActions: true,
                  onApproveKyc: () {
                    context.read<AdminBloc>().add(
                      ApproveKycRequested(user.id),
                    );
                  },
                  onRejectKyc: () {
                    _showRejectDialog(context, user.id);
                  },
                );
              },
            );
          }
          return const Center(
            child: Text(
              'Failed to load users',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Reject KYC',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Reason for rejection',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          maxLines: 3,
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
              context.read<AdminBloc>().add(
                RejectKycRequested(userId, reason: reasonController.text),
              );
              Navigator.pop(ctx);
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
