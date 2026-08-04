// lib/features/settings/auto_save_beneficiary.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BeneficiaryAutomationService extends StatefulWidget {
  const BeneficiaryAutomationService({super.key});

  @override
  State<BeneficiaryAutomationService> createState() => _BeneficiaryAutomationServiceState();
}

class _BeneficiaryAutomationServiceState extends State<BeneficiaryAutomationService> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _autoSaveBeneficiary = true; // Maps to auto_save_beneficiary column in user_settings

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchPreference();
  }

  Future<void> _fetchPreference() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('user_settings')
          .select('auto_save_beneficiary')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _autoSaveBeneficiary = response['auto_save_beneficiary'] as bool? ?? true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast('Failed to load auto-save preference', isError: true);
      }
    }
  }

  Future<void> _updatePreference(bool value) async {
    setState(() {
      _autoSaveBeneficiary = value;
      _isSaving = true;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated session');

      // Real-time synchronization upsert to Supabase user_settings table
      await _supabase.from('user_settings').upsert({
        'user_id': user.id,
        'auto_save_beneficiary': value,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (mounted) {
        _showToast(
          value ? 'Auto-save beneficiary enabled successfully' : 'Auto-save beneficiary disabled',
        );
      }
    } catch (e) {
      if (mounted) {
        // Revert UI state on failure
        setState(() => _autoSaveBeneficiary = !value);
        _showToast('Error updating preference: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100];
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Beneficiary Auto-Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Professional fintech description card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_added_rounded, color: accentColor, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Automatically save recipient usernames to your beneficiary roster instantly after every successful money transfer.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Clean Toggle Container
                Card(
                  color: cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SwitchListTile.adaptive(
                      activeColor: accentColor,
                      title: const Text(
                        'Auto-Save Recipients',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Always save the username you send money to in real-time.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      value: _autoSaveBeneficiary,
                      onChanged: _isSaving ? null : (val) => _updatePreference(val),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}