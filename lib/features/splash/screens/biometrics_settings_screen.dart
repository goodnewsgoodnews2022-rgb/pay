// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BiometricsSettingsScreen extends StatefulWidget {
  const BiometricsSettingsScreen({super.key});

  @override
  State<BiometricsSettingsScreen> createState() => _BiometricsSettingsScreenState();
}

class _BiometricsSettingsScreenState extends State<BiometricsSettingsScreen> {
  bool _isBiometricsEnabled = false;

  void _toggleBiometrics(bool value) {
    setState(() => _isBiometricsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Biometric authentication enabled successfully.' : 'Biometric authentication disabled.'),
        backgroundColor: value ? const Color(0xFF10B981) : Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic configurations mapping
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
        title: Text('Biometric Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hardware Authentication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 6),
              Text('Use your device biometric scanners (FaceID / Fingerprint) to unlock your dashboard instantly.', style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.3)),
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
                    Icon(Icons.fingerprint_rounded, size: 28, color: const Color(0xFF10B981)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enable Biometrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
                          const SizedBox(height: 2),
                          Text('Bypass standard passwords securely', style: TextStyle(fontSize: 11, color: subtitleColor)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isBiometricsEnabled,
                      activeColor: const Color(0xFF10B981),
                      onChanged: _toggleBiometrics,
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