// lib/core/network/supabase_client.dart

// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/config/environment.dart';

/// Centralized Core Initialization Engine for the Supabase backend.
/// This class configures and maintains the primary authenticated network channels
/// for database streams, row-level authentication, and system storage.
class SupabaseClientService {
  // Private internal constructor to enforce the Singleton design pattern
  SupabaseClientService._internal();

  /// Single, shared global gateway instance
  static final SupabaseClientService instance = SupabaseClientService._internal();

  bool _isInitialized = false;

  /// Initializes the remote database instance channel securely.
  /// This must be executed exactly once at the absolute root initialization of the application runtime.
  Future<void> initialize() async {
    if (_isInitialized) {
      print('ℹ️ Supabase Client Service has already been initialized. Skipping execution block.');
      return;
    }

    try {
      // 1. Verify our compile-time environment tokens are valid before connecting
      if (Environment.supabaseUrl.contains('placeholder') || 
          Environment.supabaseAnonKey.contains('placeholder')) {
        throw Exception(
          'CRITICAL EXECUTION ERROR: Cannot initialize Supabase backend using fallback placeholder credentials. '
          'Please verify that your build configuration contains valid environment variables.'
        );
      }

      // 2. Fire up the native client connection pool infrastructure
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        publishableKey: Environment.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // Enforces modern, secure cryptographic authorization flow
        ),
      );

      _isInitialized = true;
      print('🚀 [NETWORK-INFRA] Supabase Database & Auth clusters successfully initialized.');
    } catch (e) {
      print('❌ [CRITICAL-INFRA-ERROR] Failed to establish standard handshake with Supabase cluster: $e');
      rethrow;
    }
  }

  /// Exposes the authenticated direct database engine client.
  /// Your team members will use this to run queries: e.g., `SupabaseClientService.instance.client.from('wallets').select();`
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('CRITICAL: Attempted to access Supabase client before calling initialize().');
    }
    return Supabase.instance.client;
  }

  /// Helper getter to quickly evaluate current session authentication states app-wide
  Session? get currentSession => client.auth.currentSession;

  /// Helper getter to fetch the logged-in user identifier
  User? get currentUser => client.auth.currentUser;
}