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

  /// Flutterwave Public Key environment mapping
  static const String flutterwavePublicKey = String.fromEnvironment(
    'FLUTTERWAVE_PUBLIC_KEY',
    defaultValue: 'FLWPUBK_TEST-ba6fd099c1d6d6269da9852637b0563c-X',
  );

  /// 🚀 ADDED: Flutterwave Secret Key environment mapping
  static const String flutterwaveSecretKey = String.fromEnvironment(
    'FLUTTERWAVE_SECRET_KEY',
    defaultValue: 'FLWSECK_TEST-07e819a991ccfe75ddac4a9fbb8a75d3-X',
  );

  /// 🚀 ADDED: NowPayments API Key environment mapping
  static const String nowPaymentsApiKey = String.fromEnvironment(
    'NOWPAY_API_KEY',
    defaultValue: 'N8BR5V4-9X54A57-GT8QD1Z-P4GPCHX',
  );

  static const String mainnetRpcUrl = String.fromEnvironment(
    'MAINNET_RPC_URL',
    defaultValue: 'https://eth-mainnet.g.alchemy.com/v2/FLWPUBK_TEST-c657e96bb010c74e88ff4beb11d61677-X',
  );

  /// Helper to assert configurations are valid during development stages.
  static void validate() {
    if (supabaseUrl.contains('placeholder') || supabaseAnonKey.contains('placeholder')) {
      print('⚠️ WARNING: Supabase configurations are using fallback placeholder tokens.');
    }
    if (flutterwavePublicKey.contains('FLWPUBK_TEST') || flutterwaveSecretKey.contains('FLWSECK_TEST')) {
      print('⚠️ WARNING: Flutterwave keys are using placeholder default values.');
    }
    if (nowPaymentsApiKey.isEmpty) {
      print('⚠️ WARNING: NowPayments API Key is empty.');
    }
  }
}