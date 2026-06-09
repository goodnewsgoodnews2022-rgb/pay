import 'package:fintech/features/fiat_wallet/domain/entities/fiat_account.dart';
import 'package:fintech/features/fiat_wallet/domain/entities/fiat_transaction.dart';
import 'package:fintech/features/fiat_wallet/domain/repositories/fiat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fiat_account_model.dart';
import '../models/fiat_transaction_model.dart';

class FiatRepositoryImpl implements FiatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<FiatAccount>> getFiatBalances(String userId) async {
    final response = await _supabase
        .from('fiat_wallets')
        .select()
        .eq('user_id', userId)
        .order('currency');

    return (response as List)
        .map((json) => FiatAccountModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> deposit(
    String walletId,
    double amount,
    String reference,
  ) async {
    await _supabase.rpc(
      'deposit_fiat',
      params: {
        'p_wallet_id': walletId,
        'p_amount': amount,
        'p_reference': reference,
      },
    );
  }

  @override
  Future<void> withdraw(
    String walletId,
    double amount,
    String reference,
  ) async {
    await _supabase.rpc(
      'withdraw_fiat',
      params: {
        'p_wallet_id': walletId,
        'p_amount': amount,
        'p_reference': reference,
      },
    );
  }

  @override
  Future<List<FiatTransaction>> getTransactionHistory(
    String walletId, {
    int limit = 50,
  }) async {
    final response = await _supabase
        .from('fiat_transactions')
        .select()
        .eq('wallet_id', walletId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => FiatTransactionModel.fromJson(json))
        .toList();
  }
}
