// lib/features/settings/auto_save_beneficiary.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BeneficiaryAutomationService extends StatefulWidget {
  const BeneficiaryAutomationService({super.key});

  @override
  State<BeneficiaryAutomationService> createState() => _BeneficiaryAutomationServiceState();
}

class _BeneficiaryAutomationServiceState extends State<BeneficiaryAutomationService> {
  bool _autoSaveNew = true;
  bool _notifyOnSave = true;
  bool _requirePinToDelete = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Beneficiary Auto-Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Manage how your app handles frequent transaction contacts and auto-saving mechanisms.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Core Toggle Card
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  activeColor: const Color(0xFF10B981),
                  title: const Text('Auto-Save New Transfers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Automatically add successful transactions to your beneficiary roster.', style: TextStyle(fontSize: 12)),
                  value: _autoSaveNew,
                  onChanged: (val) => setState(() => _autoSaveNew = val),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  activeColor: const Color(0xFF10B981),
                  title: const Text('Instant Smart Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Notify me explicitly when a new contact gets saved.', style: TextStyle(fontSize: 12)),
                  value: _notifyOnSave,
                  onChanged: (val) => setState(() => _notifyOnSave = val),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  activeColor: const Color(0xFF10B981),
                  title: const Text('Security Lock PIN Guard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Require transaction PIN validation before manual beneficiary updates.', style: TextStyle(fontSize: 12)),
                  value: _requirePinToDelete,
                  onChanged: (val) => setState(() => _requirePinToDelete = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Settings Action Button
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Automation parameters updated successfully'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Automation Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}