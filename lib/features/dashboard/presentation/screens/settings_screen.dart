// ignore_for_file: depend_on_referenced_packages, unused_import, deprecated_member_use, duplicate_import

import 'package:fintech/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // 🟢 DYNAMIC: Inherits color directly from the active theme configuration canvas
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Theme Dark Canvas Colo, 
      appBar: AppBar(
        title: Text(
          'Settings', 
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // 🌐 GENERAL
          _buildCategoryHeader(context, 'General'),
          _buildSettingsTile(context, Icons.language_rounded, 'Language', () => context.push('/settings/language')),
          _buildSettingsTile(context, Icons.monetization_on_outlined, 'Currency (NGN, USD, EUR)', () => context.push('/settings/currency')),
          const Divider(color: Colors.white10),

          // 🔒 PRIVACY
          _buildCategoryHeader(context, 'Privacy'),
          _buildSettingsTile(context, Icons.admin_panel_settings_outlined, 'Data Sharing Preferences', () => context.push('/settings/privacy-sharing')),
          _buildSettingsTile(context, Icons.cloud_download_outlined, 'Download My Data', () => context.push('/settings/download-data')),
          _buildSettingsTile(context, Icons.delete_forever_outlined, 'Delete Account', () => context.push('/settings/delete-account'), isDestructive: true),
          const Divider(color: Colors.white10),

          // 🎨 APPEARANCE (Now fully interactive with real real-time reactive engines)
          _buildCategoryHeader(context, 'Appearance'),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeNotifier,
            builder: (context, currentMode, _) {
              return Column(
                children: [
                  _buildThemeSelectionTile(
                    context,
                    icon: Icons.light_mode_outlined,
                    title: 'Light Mode',
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () => ThemeController.themeNotifier.value = ThemeMode.light,
                  ),
                  _buildThemeSelectionTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () => ThemeController.themeNotifier.value = ThemeMode.dark,
                  ),
                  _buildThemeSelectionTile(
                    context,
                    icon: Icons.brightness_auto_outlined,
                    title: 'System Default',
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () => ThemeController.themeNotifier.value = ThemeMode.system,
                  ),
                ],
              );
            },
          ),
          const Divider(color: Colors.white10),

          // 💸 TRANSACTIONS
          _buildCategoryHeader(context, 'Transactions'),
          _buildSettingsTile(context, Icons.account_balance_wallet_outlined, 'Default Wallet', () => context.push('/settings/default-wallet')),
          _buildSettingsTile(context, Icons.assignment_ind_outlined, 'Auto-save Beneficiaries', () => context.push('/settings/beneficiaries')),
          _buildSettingsTile(context, Icons.speed_rounded, 'Transaction Limits', () => context.push('/settings/limits')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        // Uses your primary brand green (0xFF00E676) declared safely inside colorScheme
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary, 
          fontSize: 13, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      leading: Icon(
        icon, 
        color: isDestructive ? Colors.redAccent : theme.colorScheme.onSurface.withOpacity(0.7), 
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : theme.colorScheme.onSurface, 
          fontSize: 14, 
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.onSurface.withOpacity(0.12), size: 12),
    );
  }

  Widget _buildThemeSelectionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      leading: Icon(
        icon, 
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7), 
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface, 
          fontSize: 14, 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 18)
          : const Icon(Icons.circle_outlined, color: Colors.transparent, size: 18),
    );
  }
}