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
        SnackBar(
          content: Text('Default payment target updated to ${type.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update preference', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090A0F) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Default Wallet Choice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildWalletOption(
                context: context,
                isDark: isDark,
                title: 'Fiat Currency Wallet',
                subtitle: 'Debit local bank account pools & card infrastructure directly.',
                value: 'fiat',
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                context: context,
                isDark: isDark,
                title: 'Web3 Smart Wallet',
                subtitle: 'Execute payments directly from your decentralized smart contract account.',
                value: 'web3',
                icon: Icons.token_outlined,
              ),
            ],
          ),
    );
  }

  Widget _buildWalletOption({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedWallet == value;
    
    // Dynamic background color based on theme and selection state
    final Color containerColor = isDark 
        ? (isSelected ? const Color(0xFF111622) : const Color(0xFF131823))
        : (isSelected ? Colors.white : Colors.grey[100]!);

    // Dynamic text colors to prevent invisible dark text on dark container
    final Color titleColor = isDark 
        ? Colors.white 
        : (isSelected ? const Color(0xFF1E293B) : const Color(0xFF1E293B));
        
    final Color subtitleColor = isDark 
        ? Colors.grey[400]! 
        : Colors.grey[600]!;

    return InkWell(
      onTap: () => _updateDefaultWallet(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF10B981) 
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && !isDark
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? const Color(0xFF10B981) : Colors.grey, 
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      color: subtitleColor, 
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) 
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
              )
          ],
        ),
      ),
    );
  }
}