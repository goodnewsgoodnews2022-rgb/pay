// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Initializing Supabase client...');
  final client = SupabaseClient(
    'https://gisrbsjzzdtmvjsdnyym.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdpc3Jic2p6emR0bXZqc2RueXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDA2OTIsImV4cCI6MjA5NTM3NjY5Mn0.crAdaSg4O6rxqwk6mdibpfdHCVoG_xOf2KPXwxH2zbM',
  );

  try {
    print('Testing query on transactions table...');
    final res = await client.from('transactions').select().limit(5);
    print('Transactions table query success:');
    print(res);
  } catch (e) {
    print('Error querying transactions: $e');
  }

  try {
    print('Testing RPC update_wallet_balance...');
    final rpcRes = await client.rpc('update_wallet_balance', params: {
      'user_id': '00000000-0000-0000-0000-000000000000',
      'amount_to_add': 0.0,
    });
    print('RPC update_wallet_balance success: $rpcRes');
  } catch (e) {
    print('Error calling RPC: $e');
  }
}

