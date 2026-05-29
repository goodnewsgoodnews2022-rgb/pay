// lib/core/shared_widgets/primary_button.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard Premium Call-To-Action button across the application.
/// Natively supports custom scaling, multi-state locks, and async loading cycles.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the active execution gate state
    final bool isInteractive = onPressed != null && !isLoading && !isDisabled;

    return SizedBox(
      width: double.infinity,
      height: 54, // Standard ergonomic height for mobile touch targets
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.dev1Silver,
          foregroundColor: AppColors.bgCanvas,
          disabledBackgroundColor: AppColors.bgSurface,
          disabledForegroundColor: AppColors.textSecondary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Premium rounded design token
          ),
        ),
        onPressed: isInteractive ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgCanvas),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}