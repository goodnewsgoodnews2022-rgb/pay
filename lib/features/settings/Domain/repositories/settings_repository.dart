// lib/features/settings/domain/repositories/settings_repository.dart

abstract class SettingsRepository {
  /// Fetches the user's current biometric authentication toggle state from persistence.
  Future<bool> getBiometricsEnabled();

  /// Persists the user's explicit preference regarding FaceID/TouchID usage.
  Future<void> setBiometricsEnabled(bool enabled);

  /// Fetches the string identifier of the current active theme design layout (e.g., 'dark' or 'light').
  Future<String> getAppTheme();

  /// Saves the user's custom choice for the interface display mode profile.
  Future<void> setAppTheme(String themeMode);
}