// lib/features/kyc/presentation/screens/biometric_setup_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KycBloc>().add(LoadBiometricStatus());
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 DYNAMIC THEME ENGINE: Checks if light mode or dark mode is running
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Adaptive theme tokens to guarantee proper visibility in both Light & Dark modes
    final canvasColor = isDarkMode ? const Color(0xFF090A0F) : const Color(0xFFF8FAFC);
    final surfaceColor = isDarkMode ? const Color(0xFF111622) : Colors.white;
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDarkMode ? Colors.grey[400]! : const Color(0xFF64748B);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'FingerPrint',
          style: TextStyle(
            color: mainTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: mainTextColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycBiometricPreferenceSaved) {
            context.pop();
          }
          if (state is KycError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
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
            return Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          }

          if (state is BiometricStatusLoaded) {
            final isEnabled = state.isEnabled;
            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 64,
                      color: isEnabled ? accentColor : secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEnabled ? 'Biometrics Enabled' : 'Biometrics Disabled',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? accentColor : mainTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnabled
                      ? 'You can use your fingerprint or Face ID to sign in securely.'
                      : 'Enable biometric scanning for instant, secure authentication.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // Professional Toggle Container Card
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SwitchListTile.adaptive(
                    activeColor: accentColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      'FingerPrint Login',
                      style: TextStyle(
                        color: mainTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        isEnabled ? 'Tap to disable biometric authentication' : 'Tap to enable biometric authentication',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    value: isEnabled,
                    onChanged: (bool newValue) {
                      if (newValue) {
                        context.read<KycBloc>().add(EnableBiometric());
                      } else {
                        context.read<KycBloc>().add(DisableBiometric());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text(
              'Unable to load biometric status',
              style: TextStyle(color: secondaryTextColor),
            ),
          );
        },
      ),
    );
  }
}