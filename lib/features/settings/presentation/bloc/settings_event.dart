// lib/features/settings/presentation/bloc/settings_event.dart

abstract class SettingsEvent {
  const SettingsEvent();
}

/// Dispatched immediately when the settings panel mounts to load cached preferences.
class LoadSettingsRequested extends SettingsEvent {
  const LoadSettingsRequested();
}

/// Dispatched when the user toggles the biometric / FaceID hardware slider switch.
class ToggleBiometricsRequested extends SettingsEvent {
  final bool enabled;

  const ToggleBiometricsRequested(this.enabled);
}

/// Dispatched when the user switches the dark/light mode interface option.
class ChangeThemeRequested extends SettingsEvent {
  final String themeMode;

  const ChangeThemeRequested(this.themeMode);
}