// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';
import '../widgets/pin_input_field.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Set PIN',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocListener<KycBloc, KycState>(
        listener: (context, state) {
          if (state is PinSetSuccess) {
            // After PIN is saved, complete KYC and update server
            context.read<KycBloc>().add(SubmitKycVerification());
          }
          if (state is KycSubmissionSuccess) {
            print(
              '🟢 KYC submission success – navigating to /biometric-setup',
            );
            // ✅ KYC complete – go to biometric setup
            context.go('/biometric-setup');
          }
          if (state is KycSubmissionFailure ||
              state is PinVerificationFailure) {
            final error = state is KycSubmissionFailure
                ? state.error
                : (state as PinVerificationFailure).error;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create a 6-digit PIN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                PinInputField(controller: _pinController),
                const SizedBox(height: 16),
                PinInputField(controller: _confirmPinController),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _pinController.text ==
                              _confirmPinController.text) {
                        context.read<KycBloc>().add(
                          SavePin(_pinController.text),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PINs do not match'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dev2Green,
                    ),
                    child: const Text(
                      'Complete KYC',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
