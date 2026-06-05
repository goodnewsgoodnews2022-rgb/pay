// lib/app/config/app_router.dart

// ignore_for_file: unused_import, unrelated_type_equality_checks, prefer_const_constructors, duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/dashboard/presentation/screens/more_screen.dart';
import '../../features/dashboard/presentation/screens/security_settings_screen.dart';
import '../../features/dashboard/presentation/screens/linked_accounts_screen.dart';
import '../../features/dashboard/presentation/screens/web3_settings_screen.dart';
import '../../features/dashboard/presentation/screens/reports_statements_screen.dart';
import '../../features/dashboard/presentation/screens/support_help_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// Feature Imports
import 'package:fintech/features/authentication/presentation/screens/login_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/signup_screen.dart';
import 'package:fintech/features/splash/screens/splash_screen.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';
import 'package:fintech/features/settings/presentation/screens/settings_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/app_navigation_shell.dart'; // 🚀 Import your parent tab navigator shell

// Bloc & Dependency Imports
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/settings/presentation/bloc/settings_bloc.dart'; 

class AppRouter {
  // Named Route Location Identifiers for Clean Architecture Reference
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
      final isSplashing = state.matchedLocation == splash;

      // Rule 1: Guard protected pages from unauthenticated sessions
      if (session == null && !isSplashing && !isLoggingIn && !isSigningUp) {
        return login;
      }
      
      // Rule 2: Redirect authenticated users away from landing screens straight to Dashboard
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
          return MultiBlocProvider(
            providers: [
              // Authentication Session Lifecycle Tracker
              BlocProvider<AuthBloc>.value(
                value: getIt<AuthBloc>(),
              ),
              // Splash Sequence Process Controller 
              // 🟢 FIXED: Removed the cascade invocation to stop asynchronous frame hit-test race-condition errors.
              BlocProvider<SplashNavigationCubit>(
                create: (context) => getIt<SplashNavigationCubit>(),
              ),
              // Inject SettingsBloc into the parent tree root to prevent provider missing crashes
              BlocProvider<SettingsBloc>(
                create: (context) => getIt<SettingsBloc>(),
              ),
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
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: dashboard,
            // 🚀 CRITICAL NAVIGATION RESTORE: Route directly to the AppNavigationShell container!
            // This displays your bottom bar tabs (Dashboard, Analysis, Ledger, More) perfectly.
            builder: (context, state) => const AppNavigationShell(),
          ),
          GoRoute(
            path: cryptoWallet,
            builder: (context, state) => const CryptoWalletScreen(),
          ),
          // Under your shell or root routes array, add these specific destination configs:
GoRoute(
  path: '/more',
  builder: (context, state) => const MoreScreen(),
),
GoRoute(
  path: '/profile',
  builder: (context, state) => const ProfileScreen(),
),
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(), // Core app preferences, theme toggle, etc.
),
GoRoute(
  path: '/security-settings',
  builder: (context, state) => const SecuritySettingsScreen(), // PIN, Password, 2FA, Biometrics
),
GoRoute(
  path: '/linked-accounts',
  builder: (context, state) => const LinkedAccountsScreen(), // Cards, bank links, wallets
),
GoRoute(
  path: '/web3-settings',
  builder: (context, state) => const Web3SettingsScreen(), // Web3 addresses & connections
),
GoRoute(
  path: '/reports-statements',
  builder: (context, state) => const ReportsStatementsScreen(), // Statements, history exports
),
GoRoute(
  path: '/support-help',
  builder: (context, state) => const SupportHelpScreen(), // Live chat, FAQ, ticket submissions
),
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Routing Path Error: ${state.error}')),
    ),
  );
}