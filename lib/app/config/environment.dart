// lib/app/config/environment.dart

// ignore_for_file: avoid_print

/// Centralized Environment Configuration Manager.
class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gisrbsjzzdtmvjsdnyym.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdpc3Jic2p6emR0bXZqc2RueXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDA2OTIsImV4cCI6MjA5NTM3NjY5Mn0.crAdaSg4O6rxqwk6mdibpfdHCVoG_xOf2KPXwxH2zbM',
  );

  // 🚀 ADD THIS: Flutterwave Public Key environment mapping
  static const String flutterwavePublicKey = String.fromEnvironment(
    'FLUTTERWAVE_PUBLIC_KEY',
    defaultValue: 'FLWPUBK_TEST-ba6fd099c1d6d6269da9852637b0563c-X', // <-- Put your real FLW public key string here!
  );

  static const String mainnetRpcUrl = String.fromEnvironment(
    'MAINNET_RPC_URL',
    defaultValue: 'https://eth-mainnet.g.alchemy.com/v2/placeholder',
  );

  /// Helper to assert configurations are valid during development stages.
  static void validate() {
    if (supabaseUrl.contains('placeholder') || supabaseAnonKey.contains('placeholder')) {
      print('⚠️ WARNING: Supabase configurations are using fallback placeholder tokens.');
    }
    if (flutterwavePublicKey.contains('FLWPUBK_TEST')) {
      print('⚠️ WARNING: Flutterwave public key is using the placeholder default value.');
    }
  }
}