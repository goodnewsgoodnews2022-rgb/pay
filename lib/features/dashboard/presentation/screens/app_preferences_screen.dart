// lib/features/dashboard/presentation/screens/app_preferences_screen.dart

// ignore_for_file: unused_local_variable, unused_element_parameter, prefer_const_constructors, unused_element, unused_field, implementation_imports, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ MAIN ACCESS & PROVIDER IMPORTS
import 'package:fintech/main.dart';
import 'package:fintech/features/dashboard/providers/wallet_provider.dart';

class AppPreferencesScreen extends ConsumerStatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  ConsumerState<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends ConsumerState<AppPreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeStateProvider);
    final isDarkPalette = Theme.of(context).brightness == Brightness.dark;

    const headerTextColor = Color(0xFF6E7A8A);
    final tileBackground = isDarkPalette ? const Color(0xFF111622) : Colors.grey[200];
    final fallbackTitleColor = isDarkPalette ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkPalette ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/more'); // ✅ FIXED: Changed from /MoreScreen to /more
            }
          },
        ),
        title: Text(
          'App Preferences',
          style: TextStyle(
            color: isDarkPalette ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSectionHeader('GENERAL', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.language_rounded,
            title: 'Language',
            onTap: () => context.push('/language'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.monetization_on_outlined,
            title: 'Currency Holdings Pool',
            onTap: () => context.push('/currency-holding'), // ✅ Navigates to main currency holding page
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('SECURITY', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () => context.push('/settings/change-password'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.pin_outlined,
            title: 'Change Transaction PIN',
            onTap: () => context.push('/settings/change-pin'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Enable Biometrics',
            onTap: () => context.push('/biometric-setup'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.vibration_rounded,
            title: 'Enable 2FA',
            onTap: () => context.push('/settings/two-factor'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.devices_rounded,
            title: 'Device Management',
            onTap: () => context.push('/settings/devices'),
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('APPEARANCE', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.wb_sunny_outlined,
            title: 'Light Mode',
            trailing: currentThemeMode == ThemeMode.light
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                : null,
            onTap: () => ref.read(themeStateProvider.notifier).state = ThemeMode.light,
          ),
          _buildMenuTile(
            context,
            icon: Icons.nightlight_round_outlined,
            title: 'Dark Mode',
            trailing: currentThemeMode == ThemeMode.dark
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                : null,
            onTap: () => ref.read(themeStateProvider.notifier).state = ThemeMode.dark,
          ),
          _buildMenuTile(
            context,
            icon: Icons.brightness_auto_outlined,
            title: 'System Default',
            trailing: currentThemeMode == ThemeMode.system
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                : null,
            onTap: () => ref.read(themeStateProvider.notifier).state = ThemeMode.system,
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('TRANSACTIONS', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Default Wallet',
            onTap: () => context.push('/settings/DefaultWalletScreen'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.assignment_turned_in_outlined,
            title: 'Auto-save Beneficiaries',
            onTap: () => context.push('/settings/BeneficiaryAutomationService'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.speed_rounded,
            title: 'Transaction Limits',
            onTap: () => context.push('/settings/TransactionLimitGuard'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 16.0, bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color iconColor = const Color(0xFF10B981),
    Color? titleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackTitleColor = isDark ? Colors.white : Colors.black87;
    final tileBackground = isDark ? const Color(0xFF111622) : Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tileBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? fallbackTitleColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF374151), size: 13),
      ),
    );
  }
}