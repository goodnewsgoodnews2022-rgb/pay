// lib/features/settings/domain/usecases/update_theme.dart

import '../repositories/settings_repository.dart';

class UpdateTheme {
  final SettingsRepository _repository;

  UpdateTheme(this._repository);

  /// Executes the business logic to switch the application's global design theme profile.
  Future<void> call(String themeMode) async {
    // Enforce basic validation constraints to prevent corrupt theme strings
    if (themeMode != 'light' && themeMode != 'dark') {
      throw ArgumentError('Invalid theme configuration string payload provided.');
    }

    await _repository.setAppTheme(themeMode);
  }
}