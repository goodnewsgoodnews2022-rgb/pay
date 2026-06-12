// ignore_for_file: prefer_const_declarations, prefer_const_literals_to_create_immutables, prefer_const_constructor, deprecated_member_use, unused_import

import 'package:fintech/features/dashboard/presentation/screens/support_center_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart'; 
import 'app_preferences_screen.dart';
import 'language_screen.dart';
import 'linked_accounts_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'account_statement_screen.dart'; 
import 'security_settings_screen.dart';
import 'settings_screen.dart';
import 'support_help_screen.dart';
import 'invite_friends_screen.dart'; // Imported your new screen target file

class MoreScreen extends StatefulWidget {
  final Function(Widget) onNavigateToSubScreen;

  const MoreScreen({
    super.key,
    required this.onNavigateToSubScreen,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Matches your dashboard surface configuration perfectly
    final titleTextColor = isDark ? Colors.white : Colors.black87;
    final sectionHeaderColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    
    // Dynamic background variables matching standard dashboard cards
    final cardBackgroundColor = isDark ? const Color(0xFF0D0C14) : Colors.grey[100];
    final cardBorderColor = isDark ? const Color(0xFF1B1A26) : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'More Options',
          style: TextStyle(fontWeight: FontWeight.bold, color: titleTextColor, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // ====================================================================
          // 👤 PROFILE LAYER
          // ====================================================================
          _buildSectionHeader('PROFILE', sectionHeaderColor),
          _buildMenuCard(
            cardBackgroundColor!,
            cardBorderColor,
            children: [
              _buildMenuTile(
                icon: Icons.person_outline_rounded,
                title: 'PROFILE',
                subtitle: 'Manage your identity settings',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const ProfileScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ====================================================================
          // ⚙️ SYSTEM SETTINGS LAYER
          // ====================================================================
          _buildSectionHeader('SETTINGS', sectionHeaderColor),
          _buildMenuCard(
            cardBackgroundColor,
            cardBorderColor,
            children: [
              _buildMenuTile(
                icon: Icons.settings_outlined,
                title: 'App Preferences',
                subtitle: 'Theme modes, display options, and data defaults',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const AppPreferencesScreen()),
              ),
              _buildDivider(isDark),
              _buildMenuTile(
                icon: Icons.security_rounded,
                title: 'Security Settings',
                subtitle: 'Biometrics, PIN codes, and recovery protocols',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const SecuritySettingsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ====================================================================
          // 💳 INTEGRATED BALANCE HUB LEDGER
          // ====================================================================
          _buildSectionHeader('LINKED ACCOUNTS', sectionHeaderColor),
          _buildMenuCard(
            cardBackgroundColor,
            cardBorderColor,
            children: [
              _buildMenuTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Bank Accounts & Cards',
                subtitle: 'Traditional funding pipelines and accounts',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const LinkedAccountsScreen()),
              ),
              _buildDivider(isDark),
              _buildMenuTile(
                icon: Icons.language_rounded,
                title: 'Web3 & Crypto Ecosystem',
                subtitle: 'Non-custodial infrastructure and networks',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const LanguageScreen()), 
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ====================================================================
          // 📊 UNIFIED TRANSACTION STATEMENTS UTILITY
          // ====================================================================
          _buildSectionHeader('REPORTS & STATEMENTS', sectionHeaderColor),
          _buildMenuCard(
            cardBackgroundColor,
            cardBorderColor,
            children: [
              _buildMenuTile(
                icon: Icons.analytics_outlined,
                title: 'Download Statements',
                subtitle: 'Export comprehensive Fiat & Web3 histories',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const AccountStatementScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ====================================================================
          // 🎁 GROWTH REFERRALS PIPELINE (Updated for Routing Navigation)
          // ====================================================================
          _buildSectionHeader('REFERRALS', sectionHeaderColor),
          _buildMenuCard(
            cardBackgroundColor,
            cardBorderColor,
            children: [
              _buildMenuTile(
                icon: Icons.card_giftcard_rounded,
                title: 'Invite Friends',
                subtitle: 'Share your code and secure transactional bonuses',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const InviteFriendsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ====================================================================
          // 💬 COMMUNICATIONS HELP SYSTEM
          // ====================================================================
          _buildSectionHeader('SUPPORT & HELP CENTER', sectionHeaderColor),
          _buildMenuCard(
            cardBackgroundColor,
            cardBorderColor,
            children: [
              _buildMenuTile(
                icon: Icons.support_agent_rounded,
                title: 'Help Desk & Live Chat',
                subtitle: 'Connect instantly with global agent support teams',
                textColor: titleTextColor,
                onTap: () => widget.onNavigateToSubScreen(const SupportCenterScreen()),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // ====================================================================
          // 🚪 SECURE SYSTEM DISCONNECT LOGOUT TRIGGER
          // ====================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.08),
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent, width: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _handleLogoutSequence(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Logout Account',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color displayColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, top: 12.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: displayColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildMenuCard(Color bg, Color border, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: isDark ? const Color(0xFF1B1A26) : Colors.grey[200],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconContainerBackground = isDark ? const Color(0xFF141321) : Colors.white;
    final iconBorderColor = isDark ? const Color(0xFF222035) : Colors.grey[300]!;
    final arrowColor = isDark ? Colors.white30 : Colors.black26;
    final neonAccentColor = const Color(0xFF00E676); // Unified vibrant tint matching your design icons

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconBorderColor, width: 0.8),
        ),
        child: Icon(icon, color: neonAccentColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 12),
    );
  }

  void _handleLogoutSequence(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0D0C14) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        content: Text('Are you sure you want to log out of your session securely?', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(innerContext);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}