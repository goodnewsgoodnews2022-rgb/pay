// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Color definitions matching modern fintech design frameworks
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
          onPressed: () => context.pop(), // Returns smoothly back to More Screen
        ),
        title: Text(
          'Support & Help Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // ====================================================================
            // 1. LIVE CHAT HERO COMPONENT (Primary Action)
            // ====================================================================
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorderColor),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: accentPrimaryColor.withOpacity(0.12),
                        child: Icon(Icons.forum_outlined, color: accentPrimaryColor, size: 24),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981), // Green Online Badge
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? const Color(0xFF151424) : Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Chat Support',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chat with an agent right now • History saved',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accentPrimaryColor),
                    onPressed: () {
                      // Routes directly to your dynamic live messaging environment
                      context.push('/Chat_UI');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeading(theme, 'Self-Service & Help Desk'),
            const SizedBox(height: 8),

            // ====================================================================
            // 2. FAQ (Frequently Asked Questions)
            // ====================================================================
            _buildSupportTile(
              theme: theme,
              icon: Icons.help_outline_rounded,
              iconColor: Colors.blueAccent,
              title: 'Frequently Asked Questions',
              subtitle: 'Limits, transaction fees, password resets',
              onTap: () => context.push('/support/faqs'),
            ),

            // ====================================================================
            // 3. CONTACT SUPPORT CHANNELS
            // ====================================================================
            _buildSupportTile(
              theme: theme,
              icon: Icons.alternate_email_rounded,
              iconColor: Colors.orangeAccent,
              title: 'Contact Support',
              subtitle: 'Reach us via Email, Phone, or WhatsApp',
              onTap: () => context.push('/support/contact'),
            ),

            // ====================================================================
            // 4. REPORT A PROBLEM / APP BUGS
            // ====================================================================
            _buildSupportTile(
              theme: theme,
              icon: Icons.bug_report_outlined,
              iconColor: Colors.redAccent,
              title: 'Report a Problem',
              subtitle: 'Failed transactions, errors, or app bugs',
              onTap: () => context.push('/support/report-problem'),
            ),

            const SizedBox(height: 16),
            _buildSectionHeading(theme, 'Security & Disputes'),
            const SizedBox(height: 8),

            // ====================================================================
            // 5. SECURITY CENTER
            // ====================================================================
            _buildSupportTile(
              theme: theme,
              icon: Icons.security_rounded,
              iconColor: Colors.tealAccent,
              title: 'Security Center',
              subtitle: 'Freeze account or report suspicious activity',
              onTap: () => context.push('/support/security-center'),
            ),

            // ====================================================================
            // 6. TRANSACTION DISPUTE TRACKER
            // ====================================================================
            _buildSupportTile(
              theme: theme,
              icon: Icons.gavel_rounded,
              iconColor: Colors.deepPurpleAccent,
              title: 'Transaction Disputes',
              subtitle: 'Select a transaction and upload evidence',
              onTap: () => context.push('/support/disputes'),
            ),

            // ====================================================================
            // 7. ANNOUNCEMENTS & STATUS
            // ====================================================================
            _buildSupportTile(
              theme: theme,
              icon: Icons.campaign_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'Announcements & Network Status',
              subtitle: 'Check system upgrades and scheduled maintenance',
              onTap: () => context.push('/support/status-announcements'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(ThemeData theme, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSupportTile({
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