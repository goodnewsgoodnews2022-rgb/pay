// lib/app/config/app_router.dart

// ignore_for_file: duplicate_import

import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
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
import 'package:fintech/features/profile/presentation/screens/profile_screen.dart'; // 👤 Profile Import Added

// 🔌 Modular Feature Routes (Prevents team merge conflicts)
import 'routes/auth_routes.dart';
import 'routes/dashboard_routes.dart';
import 'routes/wallet_routes.dart';

class AppRouter {
  // Named Route Location Identifiers for Clean Architecture Reference
  static const String splash = '/';
  static const String signup = AuthRoutes.signup;
  static const String login = AuthRoutes.login;
  static const String dashboard = DashboardRoutes.dashboard;
  static const String settings = DashboardRoutes.settings;
  static const String cryptoWallet = WalletRoutes.wallet;
  static const String profile = '/profile'; // 🚀 New Profile Location Path Constant

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

      // Rule 1: Guard protected pages (including profile) from unauthenticated sessions
      if (session == null && !isSpashing && !isLoggingIn && !isSigningUp) {
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
              BlocProvider<SplashNavigationCubit>(
                create: (context) => getIt<SplashNavigationCubit>()..initializeAppGatewaySequence(),
              ),
              // Settings Operations Tracker (Scoped across features like profile and layouts)
              BlocProvider<SettingsBloc>(
                create: (context) => getIt<SettingsBloc>(),
              ),
            ],
            child: child,
          );
        },
        // 🚀 SPREAD OPERATORS: Injects your decentralized team routes cleanly
        routes: [
          GoRoute(
            path: splash,
            builder: (context, state) => const SplashScreen(),
          ),
          
          // 👤 Core Profile Route: Handles native gallery picking and Supabase metadata updates
          GoRoute(
            path: profile,
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