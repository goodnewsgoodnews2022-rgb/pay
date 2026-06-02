// lib/features/settings/data/datasources/settings_local_data_source.dart

// ignore_for_file: depend_on_referenced_packages

import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<bool> getBiometricsPreference();
  Future<void> cacheBiometricsPreference(bool enabled);
  Future<String> getThemePreference();
  Future<void> cacheThemePreference(String themeMode);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _sharedPreferences;

  // Keys used for saving data to the device storage cache
  static const String _keyBiometrics = 'cached_biometrics_enabled';
  static const String _keyTheme = 'cached_app_theme_mode';

  SettingsLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<bool> getBiometricsPreference() async {
    // Default to false if the user has never configured it
    return _sharedPreferences.getBool(_keyBiometrics) ?? false;
  }

  @override
  Future<void> cacheBiometricsPreference(bool enabled) async {
    final success = await _sharedPreferences.setBool(_keyBiometrics, enabled);
    if (!success) throw Exception('Failed to write biometrics preference to local storage device.');
  }

  @override
  Future<String> getThemePreference() async {
    // Default to dark mode for a premium FinTech UI experience
    return _sharedPreferences.getString(_keyTheme) ?? 'dark';
  }

  @override
  Future<void> cacheThemePreference(String themeMode) async {
    final success = await _sharedPreferences.setString(_keyTheme, themeMode);
    if (!success) throw Exception('Failed to write theme configuration preference to local storage device.');
  }
}