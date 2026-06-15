// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final String _referralCode = "PAY-MX982-2026";
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    setState(() {
      _isCopied = true;
    });
    
    // Reset copy indicator state after a brief delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isCopied = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _triggerNativeShareSheet() {
    // In production, integrate the 'share_plus' package: Share.share('Join me on Pay... Use code...');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening system sharing channels...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final inputBgColor = isDark ? const Color(0xFF0A0A10) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Referrals & Invites',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            // Promotional Banner Visual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentPrimaryColor, accentPrimaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Invite Friends, Earn Cash',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get \$10.00 instantly inside your ledger wallet for every new active advocate who registers using your signature network link.',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Performance Referral Metrics Dashboard
            Text('Your Referral Performance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMetricCard('Total Invites', '14', Icons.people_alt_rounded, const Color(0xFF3B82F6), cardBgColor!, cardBorderColor),
                const SizedBox(width: 12),
                _buildMetricCard('Earned Payout', '\$140.00', Icons.account_balance_wallet_rounded, const Color(0xFF10B981), cardBgColor, cardBorderColor),
              ],
            ),
            const SizedBox(height: 24),

            // Copy Action Center Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Unique Referral Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: inputBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _referralCode,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: theme.colorScheme.onSurface),
                        ),
                        IconButton(
                          icon: Icon(
                            _isCopied ? Icons.check_circle_rounded : Icons.copy_all_rounded,
                            color: _isCopied ? const Color(0xFF10B981) : accentPrimaryColor,
                            size: 20,
                          ),
                          onPressed: _copyToClipboard,
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _triggerNativeShareSheet,
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Invite Friends Instantly', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Instructional Stepper Pipeline Map
            Text('How the Payout Pipeline Works', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 12),
            _buildPipelineStep('1', 'Send Invite Link', 'Share your direct tracking code context with peer networks via SMS, Email, or WhatsApp channels.', accentPrimaryColor),
            _buildPipelineStep('2', 'Friend Registers & Verifies', 'Your contact finishes processing onboarding sequences and completes account profile activation steps.', accentPrimaryColor),
            _buildPipelineStep('3', 'Collect Wallet Rewards', 'Funds transfer instantly right into your primary transaction balance ledgers automatically.', accentPrimaryColor, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, Color bg, Color border) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 14,
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStep(String stepNumber, String title, String description, Color activeColor, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: activeColor.withOpacity(0.12),
              child: Text(stepNumber, style: TextStyle(color: activeColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 36,
                color: Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}