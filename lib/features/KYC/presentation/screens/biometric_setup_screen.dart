// lib/features/kyc/presentation/screens/biometric_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech/core/theme/app_colors.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() =>
      _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  @override
  void initState() {
    super.initState();
    // Load current biometric status when screen opens
    context.read<KycBloc>().add(LoadBiometricStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Biometric Login',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycBiometricPreferenceSaved) {
            // After saving, go back to settings
            context.pop();
          }
          if (state is KycError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(
              content: Text(state.message),
              action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            context.read<KycBloc>().add(LoadBiometricStatus());
          },
        ),
      ),
    );
  }
},
           
        builder: (context, state) {
          if (state is KycLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.dev2Green),
            );
          }

          if (state is BiometricStatusLoaded) {
            final isEnabled = state.isEnabled;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: isEnabled
                        ? AppColors.dev2Green
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isEnabled
                        ? 'Biometrics Enabled'
                        : 'Biometrics Disabled',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isEnabled
                          ? AppColors.dev2Green
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEnabled
                        ? 'You can use your fingerprint or face ID to sign in.'
                        : 'Enable biometrics for faster and more secure access.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  // Switch to toggle biometrics
                  SwitchListTile(
                    title: const Text(
                      'Enable Biometric Login',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      isEnabled ? 'Tap to disable' : 'Tap to enable',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: isEnabled,
                    activeColor: AppColors.dev2Green,
                    onChanged: (bool newValue) {
                      if (newValue) {
                        context.read<KycBloc>().add(EnableBiometric());
                      } else {
                        context.read<KycBloc>().add(DisableBiometric());
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  // Additional "Skip" or "Cancel" button (optional)
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }

          // Fallback for initial or error state
          return const Center(
            child: Text(
              'Unable to load biometric status',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }
}
