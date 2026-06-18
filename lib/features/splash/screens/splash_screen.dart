// lib/features/splash/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../presentation/splash_navigation_cubit.dart';
import '../presentation/controllers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // 🟢 Kicks off the initialization flow safely after the UI layout is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SplashNavigationCubit>().initializeAppGatewaySequence();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashNavigationCubit, SplashNavigationState>(
      listener: (context, state) {
        if (state is NavigateToLogin) {
          context.go('/login');
        } else if (state is NavigateToBiometricVerification) {
          context.go('/pin-setup'); // Specialized security wall screen
        } else if (state is NavigateToDashboard) {
          context.go('/dashboard');
        }
      },
      child: const Scaffold(
        backgroundColor: Color(0xFF0A0E17), // Theme Dark Canvas Color
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_rounded,
                size: 85,
                color: Color(0xFF00E676), // Fintech Emerald Green Accent
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}