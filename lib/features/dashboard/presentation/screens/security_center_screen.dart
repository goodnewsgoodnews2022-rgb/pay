// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  bool _isAccountFrozen = false;

  void _toggleAccountFreeze(bool value) {
    final theme = Theme.of(context);
    
    if (value) {
      // Show confirmation dialog before freezing account assets
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF151424) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Freeze Account Status?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          content: Text(
            'This will temporarily disable all outgoing transfers, card transactions, and security detail edits. You can unfreeze it instantly at any time.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isAccountFrozen = true;
                });
                Navigator.pop(context);
                _showStatusToast("Account locked and frozen successfully.", Colors.redAccent);
              },
              child: Text('Freeze Immediately', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isAccountFrozen = false;
      });
      _showStatusToast("Account features restored safely.", const Color(0xFF10B981));
    }
  }

  void _showStatusToast(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleReportAction(String eventType) {
    // Navigate straight to the problem reporting pipeline while carrying forward the contextual category type
    context.push('/support/report-problem');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(), // Navigates seamlessly back to Support Center
        ),
        title: Text(
          'Security Control Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Shield Graphic Hero Widget block
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24, top: 8),
                decoration: BoxDecoration(
                  color: (_isAccountFrozen ? Colors.redAccent : accentPrimaryColor).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isAccountFrozen ? Icons.gpp_bad_rounded : Icons.gpp_good_rounded,
                  size: 48,
                  color: _isAccountFrozen ? Colors.redAccent : const Color(0xFF10B981),
                ),
              ),
            ),

            // ====================================================================
            // FEATURE 3: FREEZE ACCOUNT TEMPORARILY
            // ====================================================================
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _isAccountFrozen ? Colors.redAccent.withOpacity(0.05) : cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isAccountFrozen ? Colors.redAccent.withOpacity(0.3) : cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.ac_unit_rounded, color: _isAccountFrozen ? Colors.redAccent : accentPrimaryColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Freeze Account Status',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isAccountFrozen ? 'Your wallet assets are currently locked' : 'Instantly disable cards & outgoing transfers',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isAccountFrozen,
                        activeColor: Colors.redAccent,
                        onChanged: _toggleAccountFreeze,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Threat & Breach Reporting',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // ====================================================================
            // FEATURE 1: REPORT SUSPICIOUS ACTIVITY
            // ====================================================================
            _buildSecurityActionTile(
              theme: theme,
              icon: Icons.analytics_outlined,
              iconColor: Colors.orangeAccent,
              title: 'Report Suspicious Activity',
              subtitle: 'Unfamiliar ledger transactions or payment logs',
              onTap: () => _handleReportAction('Suspicious Activity'),
            ),

            // ====================================================================
            // FEATURE 2: REPORT UNAUTHORIZED LOGIN ATTEMPTS
            // ====================================================================
            _buildSecurityActionTile(
              theme: theme,
              icon: Icons.no_accounts_rounded,
              iconColor: Colors.redAccent,
              title: 'Report Unauthorized Login',
              subtitle: 'New device access alerts or session bypass prompts',
              onTap: () => _handleReportAction('Unauthorized Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityActionTile({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final tileBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final tileBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tileBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tileBorderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        onTap: onTap,
      ),
    );
  }
}