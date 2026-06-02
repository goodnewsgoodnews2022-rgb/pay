import 'package:fintech/features/splash/data/datasources.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// --- Authentication Clean Architecture Imports ---
import '../../data/datasources/models/repositories/auth_repository_impl.dart';
import '../../domain/entities/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import 'auth_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // ====================================================================
  // ⚡ CORE INFRASTRUCTURE CONFIGURATIONS
  // ====================================================================
  if (!getIt.isRegistered<SupabaseClient>()) {
    getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
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
  
  // 2. Domain Domain Layer Use Case Registrations
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
}