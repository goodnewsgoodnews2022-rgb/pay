// lib/features/kyc/presentation/screens/biometric_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech/core/theme/app_colors.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';

class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Secure Your Account',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocListener<KycBloc, KycState>(
          listener: (context, state) {
            if (state is KycBiometricPreferenceSaved) {
              // ✅ Navigate to dashboard after biometric preference is saved
              context.go('/dashboard');
            }
            if (state is KycError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 80,
                color: AppColors.dev2Green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Enable Biometric Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Use your fingerprint or face ID for faster and more secure access to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Dispatch event to enable biometrics
                        context.read<KycBloc>().add(EnableBiometric());
                      },
                      icon: const Icon(
                        Icons.fingerprint,
                        color: Colors.black,
                      ),
                      label: const Text('Enable Biometrics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dev2Green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Skip biometrics – also saves preference (false)
                      context.read<KycBloc>().add(SkipBiometric());
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
