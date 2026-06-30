// lib/main.dart

// ignore_for_file: deprecated_member_use, avoid_print

import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';
import 'package:fintech/features/KYC/presentation/bloc/kyc_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_state.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/notifications/presentation/bloc/notification_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added dependency import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Riverpod Theme Provider
final themeStateProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  widgetsBinding.deferFirstFrame();

  // Load environment configurations before validated dependencies run
  try {
    debugPrint("Loading environment variables...");
    await dotenv.load(fileName: ".env");
    debugPrint("✅ Environment loaded successfully!");
  } catch (e) {
    debugPrint("⚠️ Warning: Environment config file (.env) failed to load: $e");
    debugPrint("Verify that your .env file is present at the project root and is declared in your pubspec.yaml assets.");
  }

  // 1. Core Framework Initializations using Environment Manager constants
  try {
    debugPrint("Initializing Supabase...");
    Environment.validate(); // Ensure credentials are sane
    
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint("❌ Core Error: Supabase initialization crashed.");
    debugPrint(e.toString());
  }

  // 2. Dependency Injection Registrations
  try {
    debugPrint("Initializing GetIt dependencies...");
    await setupDependencies();
    await getIt.allReady();

    debugPrint("AuthBloc registered: ${getIt.isRegistered<AuthBloc>()}");
    debugPrint("NotificationBloc registered: ${getIt.isRegistered<NotificationBloc>()}");
    debugPrint("KycBloc registered: ${getIt.isRegistered<KycBloc>()}");
  } catch (e, stackTrace) {
    debugPrint("❌ Core Error: GetIt Dependency Injection Registration crashed.");
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());
  } finally {
    widgetsBinding.allowFirstFrame();
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeStateProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckStatus()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
        ),
        BlocProvider<KycBloc>(
          create: (_) => getIt<KycBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint("Auth State: $state");

          if (state is AuthUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppRouter.router.go('/login');
            });
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "Pay Fintech",
          routerConfig: AppRouter.router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
        ),
      ),
    );
  }
}