// lib/app/config/app_router.dart

// ignore_for_file: prefer_const_constructors, duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// lib/app/config/app_router.dart

import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart'; // 🚨 MUST MATCH MAIN

// Feature Imports (Using package paths for professionalism)
import 'package:fintech/features/authentication/presentation/screens/login_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/signup_screen.dart';
import 'package:fintech/features/splash/screens/splash_screen.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';
import 'package:fintech/features/settings/presentation/screens/settings_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';

// Bloc & Dependency Imports
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';

class AppRouter {
  // Named Route Location Identifiers
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String cryptoWallet = '/wallet';
  static const String settings = '/settings';

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    
    // ====================================================================
    // AUTH ROUTE GUARD (Dynamic Session Interceptor)
    // ====================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.matchedLocation == login;
      final isSigningUp = state.matchedLocation == signup;

      if (session == null && state.matchedLocation != splash && !isLoggingIn && !isSigningUp) {
        return login;
      }
      
      if (session != null && (isLoggingIn || isSigningUp)) {
        return dashboard;
      }

      return null;
    },
    
    // ====================================================================
    // SCREEN DECLARATION MAPS WITH SHELL CONTEXT INJECTION
    // ====================================================================
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // 🚀 Injecting MULTIPLE providers to the route tree
          return MultiBlocProvider(
            providers: [
              // Authentication Session Tracker
              BlocProvider.value(
                value: getIt<AuthBloc>(),
              ),
              // Splash Sequence Controller
              BlocProvider(
                create: (context) => getIt<SplashNavigationCubit>()..initializeAppGatewaySequence(),
              ),
              // Future global Blocs (NotificationBloc, etc.) go here
            ],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: splash,
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: signup,
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: login,
            builder: (context, state) =>  LoginScreen(),
          ),
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: cryptoWallet,
            builder: (context, state) => const CryptoWalletScreen(),
          ),
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Routing Path Error: ${state.error}')),
    ),
  );
}
