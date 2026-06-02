// lib/features/settings/data/repositories/settings_repository_impl.dart

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<bool> getBiometricsEnabled() async {
    try {
      return await _localDataSource.getBiometricsPreference();
    } catch (e) {
      // Log exception internally and fallback safely to preserve user experience
      return false;
    }
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      await _localDataSource.cacheBiometricsPreference(enabled);
      
      // 💡 Future Expansion: If you want to sync this setting to Supabase:
      // final userId = Supabase.instance.client.auth.currentUser?.id;
      // if (userId != null) {
      //   await _remoteDataSource.updateUserSettings(userId, {'biometrics': enabled});
      // }
    } catch (e) {
      throw Exception('Repository Error altering biometrics preference state: $e');
    }
  }

  @override
  Future<String> getAppTheme() async {
    try {
      return await _localDataSource.getThemePreference();
    } catch (e) {
      return 'dark'; // Hard fallback to preserve design continuity
    }
  }

  @override
  Future<void> setAppTheme(String themeMode) async {
    try {
      await _localDataSource.cacheThemePreference(themeMode);
    } catch (e) {
      throw Exception('Repository Error altering system layout theme profile: $e');
    }
  }
}