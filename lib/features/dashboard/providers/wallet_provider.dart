import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This provider streams the current user's fiat wallet directly from Supabase
final fiatWalletStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final supabase = Supabase.instance.client;
  final currentUserId = supabase.auth.currentUser?.id;

  if (currentUserId == null) {
    return Stream.value(null);
  }

  return supabase
      .from('fiat_wallets')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', currentUserId)
      .map((maps) => maps.isNotEmpty ? maps.first : null);
});