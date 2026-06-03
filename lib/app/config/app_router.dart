// ignore_for_file: prefer_const_constructors, duplicate_import

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

class AppRouter {
  // Named Route Location Identifiers
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

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
          // Injecting MULTIPLE providers to the overall route tree frame
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
          // 🚀 CRITICAL UPDATE: Pointing root core path directly to your navigation shell
          GoRoute(
            path: dashboard,
            builder: (context, state) => const AppNavigationShell(),
          ),
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Routing Path Error: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}