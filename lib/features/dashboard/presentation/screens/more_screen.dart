// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17), // Theme Dark Canvas Color
      appBar: AppBar(
        title: const Text('More Options', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E17),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // 👤 PROFILE SECTION
          _buildSectionHeader('👤 PROFILE'),
          _buildMenuTile(
            icon: Icons.person_outline_rounded,
            title: 'PROFILE',
            // 🟢 FIXED: Lowercase clean routing pattern to prevent route mismatches
            onTap: () => context.push('/profile'), 
          ),
          const Divider(color: Colors.white10),

          // ⚙️ SETTINGS SECTION
          _buildSectionHeader('⚙️ SETTINGS'),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'App Preferences',
            onTap: () => context.push('/settings'),
          ),
          _buildMenuTile(
            icon: Icons.security_rounded,
            title: 'Security Settings',
            onTap: () => context.push('/security-settings'),
          ),
          const Divider(color: Colors.white10),

          // 💳 LINKED ACCOUNTS SECTION
          _buildSectionHeader('💳 LINKED ACCOUNTS'),
          _buildMenuTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Bank Accounts & Cards',
            onTap: () => context.push('/linked-accounts'),
          ),
          _buildMenuTile(
            icon: Icons.language_rounded,
            title: 'Web3 & Crypto Ecosystem',
            onTap: () => context.push('/web3-settings'),
          ),
          const Divider(color: Colors.white10),

          // 📊 REPORTS & STATEMENTS
          _buildSectionHeader('📊 REPORTS & STATEMENTS'),
          _buildMenuTile(
            icon: Icons.analytics_outlined,
            title: 'Download Statements',
            onTap: () => context.push('/reports-statements'),
          ),
          const Divider(color: Colors.white10),

          // 🎁 REFERRALS
          _buildSectionHeader('🎁 REFERRALS'),
          _buildMenuTile(
            icon: Icons.card_giftcard_rounded,
            title: 'Invite Friends',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral invitation link copied!')),
              );
            },
          ),
          const Divider(color: Colors.white10),

          // 💬 SUPPORT & HELP CENTER
          _buildSectionHeader('💬 SUPPORT & HELP CENTER'),
          _buildMenuTile(
            icon: Icons.support_agent_rounded,
            title: 'Help Desk & Live Chat',
            onTap: () => context.push('/support-help'),
          ),
          const SizedBox(height: 32),

          // 🚪 LOGOUT SYSTEM ACTION BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _handleLogoutSequence(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Logout Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38, 
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF161F30), 
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00E676), size: 22), 
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
    );
  }

  void _handleLogoutSequence(BuildContext context) {
    context.go('/login');
  }
}