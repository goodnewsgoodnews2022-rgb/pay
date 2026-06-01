// lib/features/splash/data/datasources/session_local_check.dart

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SessionLocalCheck {
  /// Verifies if a valid remote backend session exists.
  bool isServerSessionValid();

  /// Checks if the user has enabled secure biometric verification locally.
  Future<bool> isBiometricAuthEnabled();
}

class SessionLocalCheckImpl implements SessionLocalCheck {
  final SupabaseClient _supabaseClient;
  // In production, inject a local secure storage service here (e.g., FlutterSecureStorage)

  SessionLocalCheckImpl(this._supabaseClient);

  @override
  bool isServerSessionValid() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null || session.isExpired) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> isBiometricAuthEnabled() async {
    try {
      // Simulation of a native device secure storage preference check.
      // e.g., await _secureStorage.read(key: 'biometric_enabled') == 'true';
      await Future.delayed(const Duration(milliseconds: 200)); 
      return true; 
    } catch (_) {
      return false;
    }
  }
}