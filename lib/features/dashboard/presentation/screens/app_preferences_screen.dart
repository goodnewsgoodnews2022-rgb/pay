// lib/features/dashboard/presentation/screens/app_preferences_screen.dart

// ignore_for_file: recursive_getters, implementation_imports, must_be_immutable, unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

final themeStateProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👁️ Watch the active state provider (Light Mode, Dark Mode, or System Default)
    final currentThemeMode = ref.watch(themeStateProvider);
    final isDarkPalette = Theme.of(context).brightness == Brightness.dark;

    // Layout configuration constants 
    const headerTextColor = Color(0xFF6E7A8A); 
    final tileContainerColor = isDarkPalette ? const Color(0xFF111622) : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded, 
            color: isDarkPalette ? Colors.white : Colors.black87, 
            size: 20,
          ),
          onPressed: () => context.pop(),
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
          // 📋 GENERAL SECTION
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
            title: 'Currency (NGN, USD, EUR)',
            onTap: () => context.push('/settings/currency'),
          ),
          const SizedBox(height: 16),

          // 🛡️ SECURITY SECTION
          _buildSectionHeader('SECURITY', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () => context.push('/security-settings'),
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
            onTap: () => context.push('/settings/biometrics'),
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

          // 🔔 NOTIFICATIONS SECTION
          _buildSectionHeader('NOTIFICATIONS', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            onTap: () => context.push('/settings/notifications-push'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.mail_outline_rounded,
            title: 'Email Notifications',
            onTap: () => context.push('/settings/notifications-email'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.sms_outlined,
            title: 'SMS Notifications',
            onTap: () => context.push('/settings/notifications-sms'),
          ),
          const SizedBox(height: 16),

          // 🔒 PRIVACY SECTION
          _buildSectionHeader('PRIVACY', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Data Sharing Preferences',
            onTap: () => context.push('/settings/privacy-sharing'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.download_for_offline_outlined,
            title: 'Download My Data',
            onTap: () => context.push('/settings/download-data'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            titleColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () => context.push('/settings/delete-account'),
          ),
          const SizedBox(height: 16),

          // 🎨 APPEARANCE SECTION
          _buildSectionHeader('APPEARANCE', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.wb_sunny_outlined,
            title: 'Light Mode',
            // If theme is currently Light Mode, swap the arrow out for a brand checkmark
            trailing: currentThemeMode == ThemeMode.light
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                : null,
            onTap: () => ref.read(themeStateProvider.notifier).state = ThemeMode.light,
          ),
          _buildMenuTile(
            context,
            icon: Icons.nightlight_round_outlined,
            title: 'Dark Mode',
            // If theme is currently Dark Mode, swap the arrow out for a brand checkmark
            trailing: currentThemeMode == ThemeMode.dark
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                : null,
            onTap: () => ref.read(themeStateProvider.notifier).state = ThemeMode.dark,
          ),
          _buildMenuTile(
            context,
            icon: Icons.brightness_auto_outlined,
            title: 'System Default',
            // If theme is currently following system preferences, swap the arrow out for a brand checkmark
            trailing: currentThemeMode == ThemeMode.system
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                : null,
            onTap: () => ref.read(themeStateProvider.notifier).state = ThemeMode.system,
          ),
          const SizedBox(height: 16),

          // 💸 TRANSACTIONS SECTION
          _buildSectionHeader('TRANSACTIONS', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Default Wallet',
            onTap: () => context.push('/settings/transactions/default-wallet'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.assignment_turned_in_outlined,
            title: 'Auto-save Beneficiaries',
            onTap: () => context.push('/settings/transactions/beneficiaries'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.speed_rounded,
            title: 'Transaction Limits',
            onTap: () => context.push('/transaction-settings'),
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
        trailing: trailing ?? const Icon(
          Icons.arrow_forward_ios_rounded, 
          color: Color(0xFF374151), 
          size: 13,
        ),
      ),
    );
  }
}