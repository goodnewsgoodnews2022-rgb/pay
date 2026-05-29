// lib/core/shared_widgets/status_badge.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TransactionStatus { success, pending, failed }

/// Status indicator widget used to display transaction or compliance tracking states.
/// Automatically parses target states into matching premium theme accents.
class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    Color containerColor;
    String text;

    switch (status) {
      case TransactionStatus.success:
        text = 'Completed';
        labelColor = AppColors.success;
        containerColor = AppColors.success.withOpacity(0.12);
        break;
      case TransactionStatus.pending:
        text = 'Processing';
        labelColor = const Color(0xFFFFB300); // Premium Gold Amber color
        containerColor = const Color(0xFFFFB300).withOpacity(0.12);
        break;
      case TransactionStatus.failed:
        text = 'Declined';
        labelColor = AppColors.error;
        containerColor = AppColors.error.withOpacity(0.12);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30), // Pill-shaped design asset
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: labelColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}