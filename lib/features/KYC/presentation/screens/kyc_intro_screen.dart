import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';
import '../widgets/biometric_button.dart';

class KycIntroScreen extends StatelessWidget {
  const KycIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Biometric Verification',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            context.read<KycBloc>()..add(CheckBiometricAvailability()),
        child: BlocConsumer<KycBloc, KycState>(
          listener: (context, state) {
            if (state is BiometricSuccess) {
              Navigator.pushReplacementNamed(context, '/pin-setup');
            }
            if (state is BiometricFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            bool biometricSupported = false;
            if (state is BiometricAvailable) {
              biometricSupported = state.isSupported;
            }
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 80,
                    color: AppColors.dev2Green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verify your identity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We need to confirm your identity to enable all features. Please complete the following steps.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  if (biometricSupported)
                    BiometricButton(
                      onPressed: () => context.read<KycBloc>().add(
                        PerformBiometricAuth(),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/pin-setup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dev2Green,
                      ),
                      child: const Text(
                        'Continue with PIN Setup',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
