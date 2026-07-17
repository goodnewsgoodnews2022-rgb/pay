// ignore_for_file: avoid_print

import 'package:fintech/admin/domain/entities/admin_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_user_tile.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers({bool reset = false}) {
    if (reset) {
      _currentOffset = 0;
      _hasMore = true;
    }
    print('🔄 Loading users: offset=$_currentOffset, reset=$reset');
    context.read<AdminBloc>().add(
      LoadAllUsers(limit: _limit, offset: _currentOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'User Management',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => _loadUsers(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _loadUsers(reset: true);
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
                _loadUsers(reset: true);
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                }
                if (state is AdminOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.dev2Green,
                    ),
                  );
                  // Refresh list after operation with a small delay
                  print('✅ Operation success, reloading users...');
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      _loadUsers(reset: true);
                    }
                  });
                }
                if (state is AdminUsersLoaded) {
                  _hasMore = state.hasMore;
                }
              },
              builder: (context, state) {
                if (state is AdminLoading && _currentOffset == 0) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.dev1Silver,
                    ),
                  );
                }
                if (state is AdminUsersLoaded) {
                  var users = state.users;
                  if (_searchQuery.isNotEmpty) {
                    users = users
                        .where(
                          (u) =>
                              u.email.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              (u.fullName?.toLowerCase().contains(
                                    _searchQuery,
                                  ) ??
                                  false),
                        )
                        .toList();
                  }
                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == users.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentOffset += _limit;
                                  _loadUsers();
                                });
                              },
                              child: const Text('Load More'),
                            ),
                          ),
                        );
                      }
                      final user = users[index];
                      return AdminUserTile(
                        user: user,
                        onTap: () {
                          // Optional: navigate to user details
                          // context.push('/admin/user/${user.id}');
                        },
                        onSuspendToggle: () {
                          _confirmSuspendToggle(context, user);
                        },
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
          ),
        ],
      ),
    );
  }

  void _confirmSuspendToggle(BuildContext context, AdminUser user) {
    final isCurrentlySuspended = user.isSuspended;
    final action = isCurrentlySuspended ? 'Unsuspend' : 'Suspend';
    final message = isCurrentlySuspended
        ? 'Are you sure you want to unsuspend this user? They will regain full access.'
        : 'Are you sure you want to suspend this user? They will lose access to their account.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text(
          '$action User',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
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
              final suspend = !isCurrentlySuspended;
              print('🔁 Dispatching UpdateUserStatus: suspend=$suspend');
              context.read<AdminBloc>().add(
                UpdateUserStatus(
                  user.id,
                  isSuspended: suspend,
                  suspensionReason: suspend ? 'Suspended by admin' : null,
                ),
              );
            },
            child: Text(
              action,
              style: TextStyle(
                color: isCurrentlySuspended
                    ? AppColors.dev2Green
                    : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
