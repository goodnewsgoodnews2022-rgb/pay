// lib/features/settings/domain/usecases/toggle_biometrics.dart

import '../repositories/settings_repository.dart';

class ToggleBiometrics {
  final SettingsRepository _repository;

  ToggleBiometrics(this._repository);

  /// Executes the business logic to update the user's biometric state toggle.
  Future<void> call(bool enabled) async {
    // 💡 FinTech Business Logic Rule: You could add custom system checks here,
    // like verifying if the device has hardware biometrics before saving.
    
    await _repository.setBiometricsEnabled(enabled);
  }
}