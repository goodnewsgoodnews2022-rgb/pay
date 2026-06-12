// lib/app/config/app_router.dart

// ignore_for_file: unused_import, unrelated_type_equality_checks, prefer_const_constructors, duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'package:fintech/features/dashboard/presentation/screens/app_preferences_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/transaction_settings_screen.dart';
import '../../features/dashboard/presentation/screens/more_screen.dart';
import '../../features/dashboard/presentation/screens/security_settings_screen.dart';
import '../../features/dashboard/presentation/screens/linked_accounts_screen.dart';
import '../../features/dashboard/presentation/screens/web3_settings_screen.dart';
import '../../features/dashboard/presentation/screens/reports_statements_screen.dart';
import '../../features/dashboard/presentation/screens/support_help_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/login_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/signup_screen.dart';
import 'package:fintech/features/splash/screens/splash_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/app_navigation_shell.dart';
import 'package:fintech/features/dashboard/presentation/screens/language_screen.dart';

// Bloc & Dependency Imports
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/settings/presentation/bloc/settings_bloc.dart'; 
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart'; 

class AppRouter {
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String cryptoWallet = '/wallet';
  static const String appPreferences = '/app-preferences';
  static const String language = '/language';

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    
    // ====================================================================
    // AUTH ROUTE GUARD
    // ====================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.matchedLocation == login;
      final isSigningUp = state.matchedLocation == signup;
      final isSplashing = state.matchedLocation == splash;

      if (session == null && !isSplashing && !isLoggingIn && !isSigningUp) {
        return login;
      }
      
      if (session != null && (isLoggingIn || isSigningUp)) {
        return dashboard;
      }

      return null;
    },

    // ====================================================================
    // SCREEN DECLARATION MAPS
    // ====================================================================
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final authBloc = getIt<AuthBloc>();

          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<SplashNavigationCubit>(
                create: (context) => getIt<SplashNavigationCubit>()..initializeAppGatewaySequence(),
              ),
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
            path: login,
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: dashboard,
            builder: (context, state) => const AppNavigationShell(),
          ),
          GoRoute(
            path: cryptoWallet,
            builder: (context, state) => const CryptoWalletScreen(),
          ),

          // 📂 MORE SCREEN ROOT PATH
          GoRoute(
            path: '/more',
            builder: (context, state) => MoreScreen(
              onNavigateToSubScreen: (route) => context.go(route as String),
            ),
          ),

          // ⚙️ APP PREFERENCES CLEAN ROOT PATH
          GoRoute(
            path: appPreferences,
            builder: (context, state) => const AppPreferencesScreen(),
          ),

          // 🚀 LANGUAGE SELECTION SCREEN ROUTE
          GoRoute(
            path: language,
            builder: (context, state) => const LanguageScreen(),
          ),

          // Standalone Sub-features Root Path Definitions
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/security-settings',
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          GoRoute(
            path: '/transaction-settings',
            builder: (context, state) => const TransactionSettingsScreen(),
          ),
          GoRoute(
            path: '/linked-accounts',
            builder: (context, state) => const LinkedAccountsScreen(),
          ),
          GoRoute(
            path: '/web3-settings',
            builder: (context, state) => const Web3SettingsScreen(),
          ),
          GoRoute(
            path: '/reports-statements',
            builder: (context, state) => const ReportsStatementsScreen(),
          ),
          GoRoute(
            path: '/support-help',
            builder: (context, state) => const SupportHelpScreen(),
          ),
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Routing Path Error: ${state.error}')),
    ),
  );
}