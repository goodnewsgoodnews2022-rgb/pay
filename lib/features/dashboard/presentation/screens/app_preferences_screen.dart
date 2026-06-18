// lib/features/dashboard/presentation/screens/app_preferences_screen.dart

// ignore_for_file: implementation_imports, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ CRITICAL FIX: Import your main.dart file to gain access to the global themeStateProvider
import 'package:fintech/main.dart';

class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👁️ Watch the global state provider from main.dart
    final currentThemeMode = ref.watch(themeStateProvider);
    final isDarkPalette = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Layout configuration constants
    const headerTextColor = Color(0xFF6E7A8A);
    final tileBackground = isDarkPalette
        ? const Color(0xFF111622)
        : Colors.grey[200];
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

          // ====================================================================
          // REAL-TIME MULTI-CURRENCY HOLDINGS DROP-DOWN MENU
          // ====================================================================
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: currentUserId != null
                  ? Supabase.instance.client
                        .from('wallets')
                        .stream(primaryKey: ['user_id'])
                        .eq('user_id', currentUserId)
                  : null,
              builder: (context, snapshot) {
                double ngn = 0.0;
                double usd = 0.0;
                double eur = 0.0;

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final data = snapshot.data!.first;
                  ngn = (data['ngn_balance'] ?? 0.0).toDouble();
                  usd = (data['usd_balance'] ?? 0.0).toDouble();
                  eur = (data['eur_balance'] ?? 0.0).toDouble();
                }

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tileBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.monetization_on_outlined,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Currency Holdings Pool',
                      style: TextStyle(
                        color: fallbackTitleColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDarkPalette
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    children: [
                      _buildSubCurrencyRow(
                        context,
                        label: 'Nigerian Naira',
                        value: '₦${ngn.toStringAsFixed(2)}',
                      ),
                      _buildSubCurrencyRow(
                        context,
                        label: 'United States Dollar',
                        value: '\$${usd.toStringAsFixed(2)}',
                      ),
                      _buildSubCurrencyRow(
                        context,
                        label: 'Euro Currency Ledger',
                        value: '€${eur.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 🛡️ SECURITY SECTION
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
            trailing: currentThemeMode == ThemeMode.light
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  )
                : null,
            onTap: () =>
                ref.read(themeStateProvider.notifier).state = ThemeMode.light,
          ),
          _buildMenuTile(
            context,
            icon: Icons.nightlight_round_outlined,
            title: 'Dark Mode',
            trailing: currentThemeMode == ThemeMode.dark
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  )
                : null,
            onTap: () =>
                ref.read(themeStateProvider.notifier).state = ThemeMode.dark,
          ),
          _buildMenuTile(
            context,
            icon: Icons.brightness_auto_outlined,
            title: 'System Default',
            trailing: currentThemeMode == ThemeMode.system
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  )
                : null,
            onTap: () =>
                ref.read(themeStateProvider.notifier).state = ThemeMode.system,
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
        trailing:
            trailing ??
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF374151),
              size: 13,
            ),
      ),
    );
  }

  Widget _buildSubCurrencyRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        left: 52.0,
        top: 4.0,
        bottom: 4.0,
        right: 4.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D111A) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF1A202E) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
