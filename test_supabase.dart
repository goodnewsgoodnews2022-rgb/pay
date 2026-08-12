// ignore_for_file: avoid_print, prefer_const_declarations

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Initializing Supabase client...');
  final client = SupabaseClient(
    'https://gisrbsjzzdtmvjsdnyym.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdpc3Jic2p6emR0bXZqc2RueXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDA2OTIsImV4cCI6MjA5NTM3NjY5Mn0.crAdaSg4O6rxqwk6mdibpfdHCVoG_xOf2KPXwxH2zbM',
  );

  final email = 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com';
  final password = 'password123';
  final fullName = 'Test User';
  final username = 'testuser_${DateTime.now().millisecondsSinceEpoch}';

  try {
    print('Signing up user: $email');
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
      },
    );

    final user = response.user;
    print('Auth Signup successful! User ID: ${user?.id}');

    if (user != null) {
      try {
        print('Attempting to upsert profile for User ID: ${user.id}...');
        await client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'username': username,
          'kyc_status': 'PENDING',
          'is_admin': false,
          'is_suspended': false,
        }, onConflict: 'id');
        print('Profile upsert successful!');
      } catch (e) {
        print('Profile upsert failed with error: $e');
      }

      try {
        print('Fetching the profile record for User ID: ${user.id}...');
        final profile = await client.from('profiles').select().eq('id', user.id).maybeSingle();
        print('Fetched Profile: $profile');
      } catch (e) {
        print('Failed to fetch profile: $e');
      }
    }
  } catch (e) {
    print('Signup failed: $e');
  }
}
