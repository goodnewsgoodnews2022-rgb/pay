import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';
import '../widgets/pin_input_field.dart';

class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinController = TextEditingController();
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Verify Identity',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocListener<KycBloc, KycState>(
        listener: (context, state) {
          if (state is PinVerificationSuccess) {
            Navigator.pop(context, true);
          }
          if (state is PinVerificationFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your PIN to continue',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 32),
              PinInputField(controller: pinController),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<KycBloc>().add(
                  VerifyPinForKyc(pinController.text),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dev2Green,
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
