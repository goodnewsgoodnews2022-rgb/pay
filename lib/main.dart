// lib/main.dart

// ignore_for_file: avoid_print, unused_import

import 'package:fintech/features/KYC/presentation/bloc/kyc_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Config & Theme Imports
import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';

// Bloc Imports
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:fintech/features/notifications/presentation/bloc/notification_bloc.dart';

// ✅ Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🚀 Riverpod Theme Provider
final themeStateProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.dark,
);

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  widgetsBinding.deferFirstFrame();

  try {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      publishableKey: Environment.supabaseAnonKey,
    );
    setupDependencies();
    await getIt.allReady();
  } catch (e) {
    debugPrint('❌ [CRITICAL INITIALIZATION ERROR]: $e');
  } finally {
    widgetsBinding.allowFirstFrame();
  }

  runApp(const ProviderScope(child: MyApp()));
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
        BlocProvider<KycBloc>(create: (_) => getIt<KycBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔐 [AuthBloc] State changed: $state');
          if (state is AuthUnauthenticated) {
            print('🔐 User is unauthenticated, navigating to /login');
            // ✅ Use the router instance directly – no context issues
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppRouter.router.go('/login');
            });
          }
        },
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
          // No need for navigatorKey
          debugShowCheckedModeBanner: false,
          title: 'Pay Fintech',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
        ),
      ),
    );
  }
}
