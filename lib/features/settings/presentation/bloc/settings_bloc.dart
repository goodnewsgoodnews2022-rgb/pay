// lib/features/settings/presentation/bloc/settings_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart'; // Still needed for initial load fetch
import '../../domain/usecases/toggle_biometrics.dart';
import '../../domain/usecases/update_theme.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;
  final ToggleBiometrics _toggleBiometrics;
  final UpdateTheme _updateTheme;

  SettingsBloc({
    required SettingsRepository repository,
    required ToggleBiometrics toggleBiometrics,
    required UpdateTheme updateTheme,
  })  : _repository = repository,
        _toggleBiometrics = toggleBiometrics,
        _updateTheme = updateTheme,
        super(const SettingsState(isBiometricsEnabled: false, currentTheme: 'dark')) {
          
    on<LoadSettingsRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final bio = await _repository.getBiometricsEnabled();
      final theme = await _repository.getAppTheme();
      emit(SettingsState(isBiometricsEnabled: bio, currentTheme: theme, isLoading: false));
    });

    on<ToggleBiometricsRequested>((event, emit) async {
      // 🚀 Executing the Use Case business channel cleanly
      await _toggleBiometrics(event.enabled);
      emit(state.copyWith(isBiometricsEnabled: event.enabled));
    });

    on<ChangeThemeRequested>((event, emit) async {
      // 🚀 Executing the Use Case business channel cleanly
      await _updateTheme(event.themeMode);
      emit(state.copyWith(currentTheme: event.themeMode));
    });
  }
}