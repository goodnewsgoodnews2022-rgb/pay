// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgCanvas,
        elevation: 0,
        title: const Text('Security & Settings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard(
            title: 'Biometric Handshake',
            subtitle: 'Manage FaceID and fingerprint keys',
            icon: Icons.fingerprint,
            trailing: Switch(
              value: true, 
              onChanged: (val) {}, 
              activeColor: AppColors.dev1Silver,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            title: 'Change Transaction PIN',
            subtitle: 'Authorize security parameters securely',
            icon: Icons.lock_outline,
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required String subtitle, required IconData icon, required Widget trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.dev1Silver.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.dev1Silver),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}