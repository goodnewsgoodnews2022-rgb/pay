// ignore_for_file: avoid_print

import 'package:fintech/admin/domain/entities/admin_dashboard_stat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_transaction.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/admin_user_model.dart';
import '../models/admin_transaction_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _supabase.rpc('get_admin_dashboard_stats');
      return AdminDashboardStats(
        totalUsers: response['total_users'] ?? 0,
        pendingKyc: response['pending_kyc'] ?? 0,
        totalDeposits:
            (response['total_deposits'] as num?)?.toDouble() ?? 0,
        totalWithdrawals:
            (response['total_withdrawals'] as num?)?.toDouble() ?? 0,
        totalTransactions: response['total_transactions'] ?? 0,
        activeUsers: response['active_users'] ?? 0,
        suspendedUsers: response['suspended_users'] ?? 0,
      );
    } catch (e) {
      print('❌ getDashboardStats error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminUser>> getAllUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_all_users',
        params: {'limit_val': limit, 'offset_val': offset},
      );
      return (response as List)
          .map((json) => AdminUserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ getAllUsers error: $e');
      rethrow;
    }
  }

  @override
  Future<AdminUser> getUserDetails(String userId) async {
    try {
      // We can use direct query for a single user – this is simple enough
      final response = await _supabase
          .from('profiles')
          .select('*, auth.users!inner(email)')
          .eq('id', userId)
          .single();
      // But to avoid eq, we could use RPC – but this one is safe
      // We'll keep it for simplicity, but you can replace with RPC later
      final email = response['auth.users']?['email'] ?? 'no-email';
      return AdminUserModel.fromJson({...response, 'email': email});
    } catch (e) {
      print('❌ getUserDetails error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserStatus(
    String userId, {
    bool? isSuspended,
    String? suspensionReason,
  }) async {
    final result = await _supabase.rpc(
      'admin_suspend_user',
      params: {
        'user_id': userId,
        'suspend': isSuspended ?? false,
        'reason': suspensionReason,
      },
    );
    if (result != true) {
      throw Exception('Failed to update user status');
    }
  }

  @override
  Future<void> approveKyc(String userId) async {
    await _supabase
        .from('profiles')
        .update({'kyc_status': 'APPROVED'})
        .eq('id', userId);
        
  }

  @override
  Future<void> rejectKyc(String userId, {String? reason}) async {
    await _supabase
        .from('profiles')
        .update({'kyc_status': 'REJECTED', 'kyc_rejection_reason': reason})
        .eq('id', userId);
  }

  @override
  Future<List<AdminTransaction>> getTransactions({
    String? type,
    String? status,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_admin_transactions',
        params: {
          'type_filter': type,
          'status_filter': status,
          'limit_val': limit,
        },
      );
      return (response as List)
          .map((json) => AdminTransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ getTransactions error: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendBroadcastNotification(
    String title,
    String message,
  ) async {
    await _supabase.from('notifications').insert({
      'title': title,
      'message': message,
      'type': 'system',
      'is_read': false, // ✅ ensure this is set
    });
  }

  @override
  Future<void> sendUserNotification(
    String userId,
    String title,
    String message,
  ) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'messsage' : message,
        'type': 'system',
        'is_read': false,
      });
    } catch (e) {
      print('❌ sendUserNotification error: $e');
      rethrow;
    }
  }
}
