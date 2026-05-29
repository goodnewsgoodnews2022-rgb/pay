// lib/app/splash/splash_screen.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppSession();
  }

  /// Evaluates real background data and routes the user dynamically
  Future<void> _initializeAppSession() async {
    // 1. Keep your smooth 3-second branding delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    try {
      // 2. Core Check: Does a valid Supabase authentication session exist?
      final currentSession = SupabaseClientService.instance.currentSession;
      if (currentSession != null) {
        print('🔐 [SPLASH] Valid session token verified. Routing straight to Secure Dashboard.');
        context.go('/dashboard');
      } else {
        print('🔒 [SPLASH] No active session found. Routing to standard Authentication.');
        context.go('/loginscreen'); // Points directly to Developer 2's login screen track
      }
    } catch (e) {
      print('❌ [SPLASH-ERROR] Dynamic gateway verification failed: $e');
      context.go('/loginscreen'); // Safe fallback choice if cache or database breaks on boot
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Stack(
        children: [
          Center(
            child: Text(
              'Fintech', // Your actual custom vector branding signature
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: LinearProgressIndicator(
              color: AppColors.dev1Silver,
              backgroundColor: AppColors.bgSurface,
              minHeight: 2,
            ),
          )
        ],
      ),
    );
  }
}