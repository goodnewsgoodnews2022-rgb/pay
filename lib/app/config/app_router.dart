// lib/app/config/app_router.dart

// ignore_for_file: unused_import, unrelated_type_equality_checks, prefer_const_constructors, duplicate_import

import 'package:fintech/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fintech/features/KYC/presentation/bloc/kyc_bloc.dart';
import 'package:fintech/features/KYC/presentation/screens/biometric_setup_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/kyc_intro_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/kyc_verification_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/pin_setup_screen.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_state.dart';
import 'package:fintech/features/authentication/presentation/screens/forget_password_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/analysis_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/contact_support_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/faqs_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/invite_friends_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/ledger_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/live_chat_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/report_problem_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/security_center_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/status_announcements_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/support_center_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/transaction_disputes_screen.dart';
import 'package:fintech/features/settings/auto_save_beneficiary.dart';
import 'package:fintech/features/settings/transaction_limit.dart';
import 'package:fintech/features/splash/screens/biometrics_settings_screen.dart';
import 'package:fintech/features/splash/screens/change_password_screen.dart';
import 'package:fintech/features/splash/screens/change_pin_screen.dart';
import 'package:fintech/features/splash/screens/device_management_screen.dart';
import 'package:fintech/features/splash/screens/two_factor_auth_screen.dart';
import 'package:fintech/features/support/presentation/screens/Chat_UI.dart';
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
import '../../features/dashboard/presentation/screens/support_help_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/login_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/signup_screen.dart';
import 'package:fintech/features/splash/screens/splash_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/app_navigation_shell.dart';
import 'package:fintech/features/dashboard/presentation/screens/language_screen.dart';

// ✅ ALIGNED & CLEANED CORE IMPORTS
import 'package:fintech/features/profile/presentation/default_wallet_screen.dart'; 

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
  static const String kycIntro = '/kyc-intro';
  static const String pinSetup = '/pin-setup';
  static const String kycVerification = '/kyc-verify';
  static const String biometricSetup = '/biometric-setup';
  static const String forgotPassword = '/forgot-password';
  static const String chatScreen = '/Chat_UI';
  static const String adminDashboard = '/admin-dashboard';
  

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash, 
    debugLogDiagnostics: true,

    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final authBloc = getIt<AuthBloc>();

          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<SplashNavigationCubit>(
                create: (context) => getIt<SplashNavigationCubit>(),
              ),
              BlocProvider<SettingsBloc>(
                create: (context) => getIt<SettingsBloc>(),
              ),
              BlocProvider<KycBloc>(create: (context) => getIt<KycBloc>()),
            ],
            child: child,
          );
        },
        routes: [
          // 🚀 ROOT LEVEL PRE-AUTH PATHS
          GoRoute(
            path: splash,
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/pin-setup',
            builder: (context, state) => const PinSetupScreen(), 
          ),
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),),
          GoRoute(
            path: chatScreen,
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: signup,
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: forgotPassword,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: biometricSetup,
            builder: (context, state) => const BiometricSetupScreen(),
          ),
          GoRoute(
            path: kycIntro,
            builder: (context, state) => const KycIntroScreen(),
          ),
          GoRoute(
            path: kycVerification,
            builder: (context, state) => const KycVerificationScreen(),
          ),

          // 🏛️ CORE SHELL: Binds Dashboard and App Bottom Nav tabs safely
          GoRoute(
            path: dashboard,
            builder: (context, state) => const AppNavigationShell(),
          ),
          GoRoute(
            path: '/reports-statements',
            builder: (context, state) => const AnalysisScreen(), 
          ),
          GoRoute(
            path: '/ledger', 
            builder: (context, state) => const LedgerScreen(), 
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => MoreScreen(
              onNavigateToSubScreen: (route) => context.go(route as String),
            ),
          ),

          // ⚙️ SUBSCREENS & FINANCIAL FEATURES PATHS
          GoRoute(
            path: cryptoWallet,
            builder: (context, state) => const CryptoWalletScreen(),
          ),
          GoRoute(
            path: appPreferences,
            builder: (context, state) => const AppPreferencesScreen(),
          ),
          GoRoute(
            path: '/settings/DefaultWalletScreen',
            builder: (context, state) => const DefaultWalletScreen(),
          ),
          GoRoute(
            path: '/settings/BeneficiaryAutomationService',
            builder: (context, state) => const BeneficiaryAutomationService(),
          ),
          GoRoute(
            path: '/settings/TransactionLimitGuard',
            builder: (context, state) => const TransactionLimitGuard(), // Cleaned up duplicate placeholder widget implementation
          ),
          GoRoute(
            path: language,
            builder: (context, state) => const LanguageScreen(),
          ),
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