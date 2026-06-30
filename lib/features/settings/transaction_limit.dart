import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionLimitGuard {
  static final _supabase = Supabase.instance.client;

  static Future<bool> isWithinLimitAllowed(double requestedAmount) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    // 1. Fetch user limit metrics thresholds
    final limits = await _supabase.from('user_transaction_limits').select().eq('user_id', userId).maybeSingle();
    if (limits == null) return true; // Default fallback if not customized

    final double maxPerTx = (limits['max_per_tx'] ?? 50000.0).toDouble();
    if (requestedAmount > maxPerTx) {
      throw Exception("Transaction exceeds your single limit allowance of ₦$maxPerTx.");
    }

    return true;
  }
}