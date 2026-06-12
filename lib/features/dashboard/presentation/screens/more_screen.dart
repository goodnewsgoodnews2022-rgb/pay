// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart'; // 🚀 Import your global themeStateProvider from main.dart
import 'app_preferences_screen.dart';
import 'language_screen.dart';
import 'linked_accounts_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'reports_statements_screen.dart';
import 'security_settings_screen.dart';
import 'settings_screen.dart';
import 'support_help_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic professional design constants depending on Theme Mode status
    final titleTextColor = isDark ? Colors.white : const Color(0xFF1C1B1F);
    final sectionHeaderColor = isDark ? Colors.white38 : Colors.black45;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      // ✅ PROFESSIONAL FIX: Adapts automatically to the theme background instead of forcing 0xFF0A0E17
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text(
          'More Options', 
          style: TextStyle(fontWeight: FontWeight.bold, color: titleTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // 👤 PROFILE SECTION
          _buildSectionHeader('👤 PROFILE', sectionHeaderColor),
          _buildMenuTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'PROFILE',
            textColor: titleTextColor,
            onTap: () => context.push('/profile'), 
          ),
          Divider(color: dividerColor),

          // ⚙️ SETTINGS SECTION
          _buildSectionHeader('⚙️ SETTINGS', sectionHeaderColor),
          _buildMenuTile(
            context,
            icon: Icons.settings_outlined,
            title: 'App Preferences',
            textColor: titleTextColor,
            onTap: () => context.push('/app-preferences'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.security_rounded,
            title: 'Security Settings',
            textColor: titleTextColor,
            onTap: () => context.push('/settings'),
          ),
          Divider(color: dividerColor),

          // 💳 LINKED ACCOUNTS SECTION
          _buildSectionHeader('💳 LINKED ACCOUNTS', sectionHeaderColor),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Bank Accounts & Cards',
            textColor: titleTextColor,
            onTap: () => context.push('/linked-accounts'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.language_rounded,
            title: 'Web3 & Crypto Ecosystem',
            textColor: titleTextColor,
            onTap: () => context.push('/web3-settings'),
          ),
          Divider(color: dividerColor),

          // 📊 REPORTS & STATEMENTS
          _buildSectionHeader('📊 REPORTS & STATEMENTS', sectionHeaderColor),
          _buildMenuTile(
            context,
            icon: Icons.analytics_outlined,
            title: 'Download Statements',
            textColor: titleTextColor,
            onTap: () => context.push('/reports-statements'),
          ),
          Divider(color: dividerColor),

          // 🎁 REFERRALS
          _buildSectionHeader('🎁 REFERRALS', sectionHeaderColor),
          _buildMenuTile(
            context,
            icon: Icons.card_giftcard_rounded,
            title: 'Invite Friends',
            textColor: titleTextColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral invitation link copied!')),
              );
            },
          ),
          Divider(color: dividerColor),

          // 💬 SUPPORT & HELP CENTER
          _buildSectionHeader('💬 SUPPORT & HELP CENTER', sectionHeaderColor),
          _buildMenuTile(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Help Desk & Live Chat',
            textColor: titleTextColor,
            onTap: () => context.push('/support-help'),
          ),
          const SizedBox(height: 32),

          // 🚪 LOGOUT SYSTEM ACTION BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _handleLogoutSequence(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  const Text('Logout Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // --- WIDGET GENERATOR METHODS ---

  Widget _buildSectionHeader(String title, Color displayColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: displayColor, 
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
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic background colors for the leading icon layout container
    final iconContainerBackground = isDark ? const Color(0xFF161F30) : Colors.grey[200];
    final arrowColor = isDark ? Colors.white24 : Colors.black26;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconContainerBackground, 
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00E676), size: 22), 
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 14),
    );
  }

  void _handleLogoutSequence(BuildContext context) {
    context.go('/login');
  }
}