import 'package:fintech/admin/domain/entities/admin_dashboard_stat.dart';
import 'package:fintech/admin/domain/entities/admin_transaction.dart';
import 'package:fintech/admin/domain/entities/admin_user.dart';
import 'package:fintech/admin/domain/repositories/admin_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_user_model.dart';
import '../models/admin_transaction_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await _supabase.rpc('get_admin_dashboard_stats');
    return AdminDashboardStats(
      totalUsers: response['total_users'] ?? 0,
      pendingKyc: response['pending_kyc'] ?? 0,
      totalDeposits: (response['total_deposits'] as num?)?.toDouble() ?? 0,
      totalWithdrawals:
          (response['total_withdrawals'] as num?)?.toDouble() ?? 0,
      totalTransactions: response['total_transactions'] ?? 0,
    );
  }

  @override
  Future<List<AdminUser>> getAllUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('profiles')
        .select('*, auth.users(email)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List).map((e) {
        final email = (e['auth'] as Map?)?['users']?['email'] ?? 'no-email';
      return AdminUserModel.fromJson({...e, 'email': email});
    }).toList();
  }

  @override
  Future<AdminUser> getUserDetails(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('*, auth.users(email)')
        .eq('id', userId)
        .single();
    final email = (response['auth'] as Map?)?['users']?['email'] ?? 'no-email';
    return AdminUserModel.fromJson({...response, 'email': email});
  }

  @override
  Future<void> updateUserStatus(
    String userId, {
    bool? isSuspended,
    String? suspensionReason,
  }) async {
    final updates = <String, dynamic>{};
    if (isSuspended != null) updates['is_suspended'] = isSuspended;
    if (suspensionReason != null)
      updates['suspension_reason'] = suspensionReason;
    await _supabase.from('profiles').update(updates).eq('id', userId);
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
    // Apply filters using PostgrestFilterBuilder before applying transformations
    var query = _supabase.from('fiat_transactions').select('*, profiles!inner(user_id)') as PostgrestFilterBuilder;
    if (type != null) query = query.eq('type', type) as PostgrestFilterBuilder;
    if (status != null) query = query.eq('status', status) as PostgrestFilterBuilder;
    final response = await (query.order('created_at', ascending: false).limit(limit));
    return (response as List).map((e) {
      final userEmail = e['profiles']?['email'] ?? 'unknown@example.com';
      return AdminTransactionModel.fromJson({
        ...e,
        'user_email': userEmail,
      });
    }).toList();
  }

  @override
  Future<void> sendBroadcastNotification(String title, String body) async {
    await _supabase.from('notifications').insert({
      'title': title,
      'body': body,
      'type': 'system',
      'is_read': false,
    });
  }

  @override
  Future<void> sendUserNotification(
    String userId,
    String title,
    String body,
  ) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': 'system',
      'is_read': false,
    });
  }
}
