import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BiometricButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const BiometricButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(
          isLoading ? null : Icons.fingerprint,
          color: Colors.black,
        ),
        label: Text(isLoading ? 'Verifying...' : 'Verify with Biometrics'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dev2Green,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
