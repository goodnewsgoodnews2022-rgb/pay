// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DefaultWalletScreen extends StatefulWidget {
  const DefaultWalletScreen({super.key});

  @override
  State<DefaultWalletScreen> createState() => _DefaultWalletScreenState();
}

class _DefaultWalletScreenState extends State<DefaultWalletScreen> {
  final _supabase = Supabase.instance.client;
  String _selectedWallet = 'fiat';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreference();
  }

  Future<void> _loadCurrentPreference() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final data = await _supabase.from('profiles').select('default_wallet_type').eq('id', userId).maybeSingle();
    if (data != null && data['default_wallet_type'] != null) {
      setState(() {
        _selectedWallet = data['default_wallet_type'];
      });
    }
  }

  Future<void> _updateDefaultWallet(String type) async {
    setState(() => _isSaving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('profiles').update({'default_wallet_type': type}).eq('id', userId!);
      setState(() => _selectedWallet = type);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Default payment target updated to ${type.toUpperCase()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update preference')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090A0F) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Default Wallet Choice'), backgroundColor: Colors.transparent, elevation: 0),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildWalletOption(
                title: 'Fiat Currency Wallet',
                subtitle: 'Debit local bank account pools & card infrastructure directly.',
                value: 'fiat',
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                title: 'Web3 Smart Wallet',
                subtitle: 'Execute payments directly from your decentralized smart contract account.',
                value: 'web3',
                icon: Icons.token_outlined,
              ),
            ],
          ),
    );
  }

  Widget _buildWalletOption({required String title, required String subtitle, required String value, required IconData icon}) {
    final isSelected = _selectedWallet == value;
    return InkWell(
      onTap: () => _updateDefaultWallet(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111622) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
          ],
        ),
      ),
    );
  }
}