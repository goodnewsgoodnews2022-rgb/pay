// lib/core/theme/theme_controller.dart
import 'package:flutter/material.dart';

class ThemeController {
  // Static singleton instance ensuring a single immutable point of truth
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
}