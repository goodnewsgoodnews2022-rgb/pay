// lib/features/settings/presentation/bloc/settings_state.dart

class SettingsState {
  final bool isBiometricsEnabled;
  final String currentTheme;
  final bool isLoading;
  final String? errorMessage; // 💡 Professional Addition: Catches data failures gracefully

  const SettingsState({
    required this.isBiometricsEnabled,
    required this.currentTheme,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Factory constructor providing the safe out-of-the-box layout starting parameters
  factory SettingsState.initial() {
    return const SettingsState(
      isBiometricsEnabled: false,
      currentTheme: 'dark',
      isLoading: false,
      errorMessage: null,
    );
  }

  /// Immutability pattern tracker: Allows copying states while safely modifying specific fields
  SettingsState copyWith({
    bool? isBiometricsEnabled,
    String? currentTheme,
    bool? isLoading,
    String? errorMessage, // Allows setting errors or clearing them by passing null
  }) {
    return SettingsState(
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      currentTheme: currentTheme ?? this.currentTheme,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Explicit override
    );
  }
}