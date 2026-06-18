import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  const PinInputField({
    required this.controller,
    this.obscureText = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Enter 6-digit PIN',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.dev2Green,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
