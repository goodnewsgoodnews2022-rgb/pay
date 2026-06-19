// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Core App Engine Theme compiler. Maps custom abstract semantic design
/// choices directly into Flutter hardware design widget themes.
class AppTheme {
  static ThemeData? lightTheme;

  AppTheme._();

  /// Comprehensive Dark-Mode template standardizing fintech layout specifications.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgCanvas,
      primaryColor: AppColors.dev1Silver,
      
      // Hook up global Typography tokens inside standard Flutter formats
      textTheme: const TextTheme(
        displayLarge: AppTypography.balanceDisplay,
        headlineMedium: AppTypography.headerPrimary,
        titleMedium: AppTypography.headerSecondary,
        bodyLarge: AppTypography.bodyPrimary,
        bodySmall: AppTypography.bodySecondary,
      ),

      // Standardize Top Navigation AppBars uniformly across screens
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgCanvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.headerSecondary,
      ),

      // Standardize list displays and data card sheets
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Configure globally uniform micro loader components
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.dev1Silver,
      ),
    );
  }
}