// lib/app/config/app_router.dart

import 'package:fintech/features/authentication/presentation/screens/login_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Core block context engine integration
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/splash/presentation/screens/splash_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import '../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';

class AppRouter {
  // Named Route Location Identifiers
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String cryptoWallet = '/wallet'; // Added Track 3 wallet path
  static const String settings = '/settings';

  /// Centralized Navigator Key tracking for global notifications/dialog overlays
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true, // Prints route updates directly to console for testing
    
    // ====================================================================
    // AUTH ROUTE GUARD (Dynamic Session Interceptor)
    // ====================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.matchedLocation == login;
      final isSigningUp = state.matchedLocation == signup;

      // If user isn't logged in and not on splash/login/signup tracks, force them to login
      if (session == null && state.matchedLocation != splash && !isLoggingIn && !isSigningUp) {
        return login;
      }
      
      // If user is already authenticated but trying to hit login/signup, go straight to dashboard
      if (session != null && (isLoggingIn || isSigningUp)) {
        return dashboard;
      }

      return null; // Proceed normally to requested target
    },
    
    // ====================================================================
    // SCREEN DECLARATION MAPS WITH SHELL CONTEXT INJECTION
    // ====================================================================
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider.value(
            value: getIt<AuthBloc>(), // Service locator injection pattern
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: splash,
            builder: (context, state) => const SplashScreen(), // Launches your branding sequence first
          ),
          GoRoute(
            path: signup,
            builder: (context, state) => const SignupScreen(), // Your active authentication target
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          
          // ------------------------------------------------------------------
          // Teammate Screens
          // ------------------------------------------------------------------
          GoRoute(
            path: login,
            builder: (context, state) => LoginScreen(), // Developer 2 Screen
          ),
          
          // ------------------------------------------------------------------
          // Track 3 Feature Screens (Your Workspace Modules)
          // ------------------------------------------------------------------
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardScreen(), // Linked to your custom dashboard
          ),
          GoRoute(
            path: cryptoWallet,
            builder: (context, state) => const CryptoWalletScreen(), // Linked to your custom wallet screen
          ),
        ],
      ),
    ],
    
    // Global Fallback Error Routing View Setup
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Routing Path Error: ${state.error}')),
    ),
  );
}