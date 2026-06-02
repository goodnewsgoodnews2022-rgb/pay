// ignore_for_file: depend_on_referenced_packages

import 'package:fintech/features/settings/domain/usecases/update_theme.dart';
import 'package:fintech/features/settings/domain/usecases/toggle_biometrics.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Splash Feature Modules ---
import 'package:fintech/features/splash/data/datasources.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';

// --- Settings Clean Architecture Feature Modules ---
import '../../../settings/data/datasources/settings_local_data_source.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

// --- Authentication Clean Architecture Core Imports ---
import '../../data/datasources/models/repositories/auth_repository_impl.dart';
import '../../domain/entities/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import 'auth_bloc.dart';

final getIt = GetIt.instance;

// 💡 Converted to Future<void> async to handle SharedPreferences native initialization
Future<void> setupDependencies() async {
  // ====================================================================
  // ⚡ CORE INFRASTRUCTURE CONFIGURATIONS
  // ====================================================================
  if (!getIt.isRegistered<SupabaseClient>()) {
    getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }

  // Native Device Storage Instance Injection
  if (!getIt.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  // ====================================================================
  // ⚙️ SETTINGS CLEAN ARCHITECTURE FEATURE MODULE
  // ====================================================================
  
  // 1. Local Device Cache Data Source Allocation
  if (!getIt.isRegistered<SettingsLocalDataSource>()) {
    getIt.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(getIt<SharedPreferences>()),
    );
  }

  // 2. Repository Contract Binding Link
  if (!getIt.isRegistered<SettingsRepository>()) {
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<SettingsLocalDataSource>()),
    );
  }

  // 3. UI State Management Controller Injection
  if (!getIt.isRegistered<SettingsBloc>()) {
    getIt.registerFactory(() => SettingsBloc(
      repository: getIt<SettingsRepository>(),
      toggleBiometrics: getIt<ToggleBiometrics>(),
      updateTheme: getIt<UpdateTheme>(),
    ));
  }

  // ====================================================================
  // 🛡️ SPLASH GATEWAY FEATURE MODULE
  // ====================================================================
  if (!getIt.isRegistered<SessionLocalCheck>()) {
    getIt.registerLazySingleton<SessionLocalCheck>(
      () => SessionLocalCheckImpl(getIt<SupabaseClient>()),
    );
  }
  
  if (!getIt.isRegistered<SplashNavigationCubit>()) {
    getIt.registerFactory<SplashNavigationCubit>(
      () => SplashNavigationCubit(getIt<SessionLocalCheck>()),
    );
  }

  // ====================================================================
  // 🔑 AUTHENTICATION CLEAN ARCHITECTURE CORE
  // ====================================================================
  
  // 1. Repository Implementation Allocation
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  }
  
  // 2. Domain Layer Use Case Registrations
  if (!getIt.isRegistered<SignUp>()) {
    getIt.registerLazySingleton(() => SignUp(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<SignIn>()) {
    getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<SignOut>()) {
    getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<GetCurrentUser>()) {
    getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<SendPasswordReset>()) {
    getIt.registerLazySingleton(() => SendPasswordReset(getIt<AuthRepository>()));
  }
  
  // 3. Presentation State Controllers (Factories)
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory(() => AuthBloc(
      signUp: getIt<SignUp>(),
      signIn: getIt<SignIn>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      sendPasswordReset: getIt<SendPasswordReset>(),
    ));
  }

  // Inside lib/features/authentication/presentation/bloc/bloc_dependency.dart

// 1. Register the Use Cases as Singletons
if (!getIt.isRegistered<ToggleBiometrics>()) {
  getIt.registerLazySingleton(() => ToggleBiometrics(getIt<SettingsRepository>()));
}
if (!getIt.isRegistered<UpdateTheme>()) {
  getIt.registerLazySingleton(() => UpdateTheme(getIt<SettingsRepository>()));
}

}