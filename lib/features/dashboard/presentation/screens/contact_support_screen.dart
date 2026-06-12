// ignore_for_file: prefer_const_declarations, unused_import, deprecated_member_use, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  // Helper method to verify if helpdesk operators are currently online (9 AM - 6 PM)
  bool _isSupportOperational() {
    final now = DateTime.now();
    // Operational Monday to Friday, 9:00 to 18:00
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) return false;
    return now.hour >= 9 && now.hour < 18;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLive = _isSupportOperational();

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
          'Contact Support',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // ====================================================================
            // OPERATIONAL STATUS BANNER COMPONENT
            // ====================================================================
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isLive ? const Color(0xFF10B981).withOpacity(0.06) : Colors.amber.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLive ? const Color(0xFF10B981).withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xFF10B981) : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLive ? 'Support Lines are Open' : 'Lines Closed • Response delays expected',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Our official business hours are Mon - Fri, 9:00 AM - 6:00 PM.',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Official Communication Channels',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // ====================================================================
            // 1. EMAIL SUPPORT
            // ====================================================================
            _buildContactTile(
              theme: theme,
              icon: Icons.alternate_email_rounded,
              iconColor: Colors.blueAccent,
              title: 'Email Support',
              subtitle: 'support@payfintech.com',
              trailingText: '24 hr turnaround',
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@payfintech.com',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),

            // ====================================================================
            // 2. PHONE SUPPORT
            // ====================================================================
            _buildContactTile(
              theme: theme,
              icon: Icons.phone_in_talk_rounded,
              iconColor: const Color(0xFF10B981),
              title: 'Phone Support Line',
              subtitle: '+1 (800) 555-FLUTTER',
              trailingText: 'Mon-Fri Toll-Free',
              onTap: () async {
                // Trigger native phone dialer using url_launcher
                final phoneNumber = '+18005551234'; // replace with real support number
                final uri = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),

            // ====================================================================
            // 3. WHATSAPP SUPPORT
            // ====================================================================
            _buildContactTile(
              theme: theme,
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF25D366), // WhatsApp Green Hex
              title: 'WhatsApp Secure Channel',
              subtitle: 'Chat via WhatsApp Business',
              trailingText: 'Instant replies',
              onTap: () async {
                // Open WhatsApp direct chat using wa.me deep link
                // Use E.164 number without '+' for wa.me (example placeholder)
                const phoneNumber = '18005551234';
                final message = Uri.encodeComponent('Hi, I need help with my account.');
                final uri = Uri.parse('https://wa.me/$phoneNumber?text=$message');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),

            // ====================================================================
            // 4. TELEGRAM SUPPORT
            // ====================================================================
            _buildContactTile(
              theme: theme,
              icon: Icons.telegram_rounded,
              iconColor: const Color(0xFF0088CC), // Telegram Blue Hex
              title: 'Telegram Support Bot',
              subtitle: '@PayFintechSupportBot',
              trailingText: 'Automated + Live Assist',
              onTap: () async {
                final uri = Uri.parse('https://t.me/PayFintechSupportBot');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailingText,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.open_in_new_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 4),
            Text(
              trailingText,
              style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
            )
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}