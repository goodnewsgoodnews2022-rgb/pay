// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;

  void _toggle2FA(bool value) {
    setState(() => _is2FAEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Two-Factor Authentication activated.' : 'Two-Factor Authentication deactivated.'),
        backgroundColor: value ? const Color(0xFF10B981) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardBg = isDark ? const Color(0xFF111622) : Colors.grey[100];
    final cardBorder = isDark ? const Color(0xFF1C2436) : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: titleColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Two-Factor Auth (2FA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Multi-Factor Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 6),
              Text('Add an extra layer of defense. Logins and transactions will require a secondary code generation token.', style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.3)),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.vibration_rounded, size: 28, color: const Color(0xFF10B981)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Authenticator App 2FA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
                          const SizedBox(height: 2),
                          Text('Use Google Authenticator or Authy', style: TextStyle(fontSize: 11, color: subtitleColor)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _is2FAEnabled,
                      activeColor: const Color(0xFF10B981),
                      onChanged: _toggle2FA,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}