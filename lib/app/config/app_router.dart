// lib/app/config/app_router.dart

// ignore_for_file: unused_import, duplicate_import

import 'package:fintech/admin/presentation/screens/admin_broadcast_screen.dart';
import 'package:fintech/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fintech/admin/presentation/screens/admin_kyc_review_screen.dart';
import 'package:fintech/admin/presentation/screens/admin_transactions_screen.dart';
import 'package:fintech/admin/presentation/screens/admin_users_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/biometric_setup_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/kyc_intro_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/kyc_verification_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/pin_setup_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/forget_password_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/analysis_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/app_preferences_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/language_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/ledger_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/more_screen.dart';
import 'package:fintech/features/profile/presentation/default_wallet_screen.dart';
import 'package:fintech/features/settings/auto_save_beneficiary.dart';
import 'package:fintech/features/settings/transaction_limit.dart';
import 'package:fintech/features/support/presentation/screens/Chat_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dependency Locator & State Management Imports
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';

// Feature Settings Layer Blocs (Required for Settings Screen Injection)
import 'package:fintech/features/settings/presentation/bloc/settings_bloc.dart';

// Screen Component Imports
import 'package:fintech/features/splash/screens/splash_screen.dart';
import 'package:fintech/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dependency Injector Configuration
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart'; // 🚨 MUST MATCH MAIN

// Feature Screens & Shell Importations
import 'package:fintech/features/authentication/presentation/screens/login_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/signup_screen.dart';
import 'package:fintech/features/splash/screens/splash_screen.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';
import 'package:fintech/features/dashboard/presentation/screens/app_navigation_shell.dart'; // 🚀 Added navigation shell reference

// Bloc Layer Assets
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';

// 🔌 Modular Feature Routes (Prevents team merge conflicts)
import 'routes/auth_routes.dart';
import 'routes/dashboard_routes.dart';
import 'routes/wallet_routes.dart';

class AppRouter {
  // Named Route Location Identifiers for Clean Architecture Reference
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
  static const String adminuser = '/admin/users';
  static const String adminTransactions = '/admin/transactions';
  static const String adminKyc = '/admin/kyc';
  static const String adminbroadcast = '/admin/broadcast';
  

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
      final isSpashing = state.matchedLocation == splash;

      if (session == null && !isSpashing && !isLoggingIn && !isSigningUp) {
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
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(
                value: getIt<AuthBloc>(),
              ),
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
            path: '/pin-setup',
            builder: (context, state) => const PinSetupScreen(), 
          ),
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),),
            GoRoute(path: '/admin/users',
             builder: (context, state) => const AdminUsersScreen(),),
            GoRoute(path: '/admin/transactions',
             builder: (context, state) => const AdminTransactionsScreen(),),
            GoRoute(path: '/admin/kyc',
             builder: (context, state) =>  const AdminKycReviewScreen(),),
            GoRoute(path: '/admin-broadcast',
             builder: (context, state) => const AdminBroadcastScreen(),),
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
          ...AuthRoutes.routes,
          ...DashboardRoutes.routes,
          ...WalletRoutes.routes,
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xff121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Routing Path Error: ${state.error}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
