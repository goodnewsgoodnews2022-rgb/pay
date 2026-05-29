// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography engine mapping clean, standard text scales.
/// Enforces consistent line-height intervals and weight scales across layout features.
class AppTypography {
  // Use system preferred font metrics (SanFrancisco for iOS, Roboto for Android)
  static const String _fontFamily = 'SanFrancisco';

  /// High-impact large currency or crypto balance readings
  static const TextStyle balanceDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Standard Screen Heading Titles
  static const TextStyle headerPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  /// Subsections or card element headers
  static const TextStyle headerSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Main functional text block entries
  static const TextStyle bodyPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4, // Generates optimal reading vertical constraints
  );

  /// Subtext labels, transaction item timestamps, or secondary form helper texts
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Small table data tags or pill component markings
  static const TextStyle microLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}