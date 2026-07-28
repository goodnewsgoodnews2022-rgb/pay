// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Initializing Supabase client...');
  final client = SupabaseClient(
    'https://gisrbsjzzdtmvjsdnyym.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdpc3Jic2p6emR0bXZqc2RueXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDA2OTIsImV4cCI6MjA5NTM3NjY5Mn0.crAdaSg4O6rxqwk6mdibpfdHCVoG_xOf2KPXwxH2zbM',
  );

  try {
    print('Testing query on deposits table...');
    final res = await client.from('deposits').select().limit(5);
    print('Deposits table query success:');
    print(res);
  } catch (e) {
    print('Error querying deposits: $e');
  }

  try {
    print('Testing RPC increment_balance...');
    // We try to call the increment_balance with dummy values to see if it exists (it might fail due to permissions or validation, but it will tell us if it exists)
    final rpcRes = await client.rpc('increment_balance', params: {
      'p_user_id': '00000000-0000-0000-0000-000000000000',
      'p_amount': 0.0,
    });
    print('RPC increment_balance success: $rpcRes');
  } catch (e) {
    print('Error calling RPC: $e');
  }
}
