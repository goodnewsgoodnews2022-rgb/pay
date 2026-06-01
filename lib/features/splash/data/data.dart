// lib/features/splash/data/datasources/splash_local_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SplashLocalDataSource {
  /// Checks if a valid, unexpired session token exists on the device.
  bool hasActiveSession();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final SupabaseClient _supabaseClient;

  SplashLocalDataSourceImpl(this._supabaseClient);

  @override
  bool hasActiveSession() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) return false;
    
    // Ensure token hasn't expired yet
    if (session.isExpired) return false;
    
    return true;
  }
}