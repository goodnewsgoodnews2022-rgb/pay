// lib/app/config/environment.dart

// ignore_for_file: avoid_print

/// Centralized Environment Configuration Manager.
/// This class safely abstracts sensitive API configurations away from direct code.
/// Launch variables are passed securely during compilation using environment keys:
/// e.g., flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gisrbsjzzdtmvjsdnyym.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdpc3Jic2p6emR0bXZqc2RueXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDA2OTIsImV4cCI6MjA5NTM3NjY5Mn0.crAdaSg4O6rxqwk6mdibpfdHCVoG_xOf2KPXwxH2zbM',
  );

  // You can easily scale this to include Web3 RPC Endpoints later:
  static const String mainnetRpcUrl = String.fromEnvironment(
    'MAINNET_RPC_URL',
    defaultValue: 'https://eth-mainnet.g.alchemy.com/v2/placeholder',
  );

  /// Helper to assert configurations are valid during development stages.
  static void validate() {
    if (supabaseUrl.contains('placeholder') || supabaseAnonKey.contains('placeholder')) {
      print('⚠️ WARNING: Supabase configurations are using fallback placeholder tokens. Ensure environment parameters are defined.');
    }
  }
}