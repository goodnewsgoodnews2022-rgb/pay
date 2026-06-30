// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

class BeneficiaryAutomationService {
  static final _supabase = Supabase.instance.client;

  /// Call this whenever a money transfer succeeds inside the app
  static Future<void> tryAutoSave({
    required String targetAccountOrAddress,
    required String referenceName,
    required String institution,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Verify if the user allows automatic background caching
    final profile = await _supabase.from('profiles').select('auto_save_beneficiaries').eq('id', userId).single();
    final bool allowed = profile['auto_save_beneficiaries'] ?? true;

    if (!allowed) return; // User disabled feature

    try {
      // 2. Perform an upsert into the contact node seamlessly
      await _supabase.from('beneficiaries').upsert({
        'user_id': userId,
        'account_or_address': targetAccountOrAddress,
        'beneficiary_name': referenceName,
        'institution_or_chain': institution,
      }, onConflict: 'user_id,account_or_address');
    } catch (e) {
      // Log silently to avoid breaking the core client thread payout confirmation
      print('Beneficiary background cache bypassed: $e');
    }
  }
}