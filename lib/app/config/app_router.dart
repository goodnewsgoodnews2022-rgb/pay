// lib/app/config/app_router.dart

// ignore_for_file: unused_import, unrelated_type_equality_checks, prefer_const_constructors, duplicate_import

import 'package:fintech/features/dashboard/presentation/screens/contact_support_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/faqs_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/invite_friends_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/live_chat_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/report_problem_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/security_center_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/status_announcements_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/support_center_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/transaction_disputes_screen.dart';
import 'package:fintech/features/splash/screens/biometrics_settings_screen.dart';
import 'package:fintech/features/splash/screens/change_password_screen.dart';
import 'package:fintech/features/splash/screens/change_pin_screen.dart';
import 'package:fintech/features/splash/screens/device_management_screen.dart';
import 'package:fintech/features/splash/screens/two_factor_auth_screen.dart';
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

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: login, // 💡 Starts app directly at Login Screen
    debugLogDiagnostics: true,

    // ====================================================================
    // AUTH ROUTE GUARD
    // ====================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.matchedLocation == login;
      final isSigningUp = state.matchedLocation == signup;
      final isSplashing = state.matchedLocation == splash;

      // Force users to authenticate if no session exists
      if (session == null && !isLoggingIn && !isSigningUp) {
        return login;
      }

      // If already logged in, skip auth screens and drop onto dashboard cleanly
      if (session != null && (isLoggingIn || isSigningUp || isSplashing || state.matchedLocation == '/biometrics-unlock')) {
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
                create: (context) => getIt<SplashNavigationCubit>(), 
                // 💡 Removed ..initializeAppGatewaySequence() cascade extension 
                // to prevent background logic from triggering premature biometric redirects.
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
          GoRoute(path: login, builder: (context, state) => LoginScreen()),
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
          GoRoute(
            path: '/support-center',
            builder: (context, state) => const SupportCenterScreen(),
          ),
          GoRoute(
            path: '/more/invite-friends',
            builder: (context, state) => const InviteFriendsScreen(),
          ),
          GoRoute(
            path: '/support/live-chat',
            builder: (context, state) => const LiveChatScreen(),
          ),
          GoRoute(
            path: '/support/faqs',
            builder: (context, state) => const FaqsScreen(),
          ),
          GoRoute(
            path: '/support/contact',
            builder: (context, state) => const ContactSupportScreen(),
          ),
          GoRoute(
            path: '/support/report-problem',
            builder: (context, state) => const ReportProblemScreen(),
          ),
          GoRoute(
            path: '/support/security-center',
            builder: (context, state) => const SecurityCenterScreen(),
          ),
          GoRoute(
            path: '/support/disputes',
            builder: (context, state) => const TransactionDisputesScreen(),
          ),
          GoRoute(
            path: '/support/status-announcements',
            builder: (context, state) => const StatusAnnouncementsScreen(),
          ),
          GoRoute(
            path: '/settings/change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: '/settings/change-pin',
            builder: (context, state) => const ChangePinScreen(),
          ),
          GoRoute(
            path: '/settings/devices',
            builder: (context, state) => const DeviceManagementScreen(),
          ),
          GoRoute(
            path: '/settings/two-factor',
            builder: (context, state) => const TwoFactorAuthScreen(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Routing Path Error: ${state.error}')),
    ),
  );
}