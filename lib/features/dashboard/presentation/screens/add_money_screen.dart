// lib/features/dashboard/presentation/screens/add_money_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _accountNumber;
  bool _isLoadingAccount = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAccountNumber();
  }

  /// 📥 Fetches real account number metadata asynchronously from Supabase Profiles
  Future<void> _fetchUserAccountNumber() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('profiles')
            .select('account_number')
            .eq('id', user.id)
            .maybeSingle();
        
        if (data != null && data['account_number'] != null) {
          setState(() {
            _accountNumber = data['account_number'].toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Error retrieving account tracking ID: $e');
    } finally {
      setState(() => _isLoadingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Premium dark design palette adjustments matching your fintech look
    final bool hasAccount = _accountNumber != null && _accountNumber!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Money',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        children: [
          // ====================================================================
          // 🏦 PRIMARY BANK TRANSFER DETAILED HUB CARD
          // ====================================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.push('${AppRouter.dashboard}/bank-transfer-details'),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      _buildActionIconContainer(Icons.account_balance_rounded),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bank Transfer', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Add money via mobile or internet banking', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 22),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                Text('Fintech Account Number', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),

                // Dynamic Display Logic: Evaluates user data presence
                if (_isLoadingAccount)
                  _buildShimmerPlaceholder()
                else if (!hasAccount)
                  const Text('No active account assigned', style: TextStyle(color: Colors.white24, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2))
                else
                  Text(
                    _accountNumber!,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.dev1Silver.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: !hasAccount ? null : () {
                          Clipboard.setData(ClipboardData(text: _accountNumber!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account number copied to clipboard!'), behavior: SnackBarBehavior.floating),
                          );
                        },
                        child: Text('Copy Number', style: TextStyle(color: hasAccount ? AppColors.dev1Silver : Colors.white24, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676), // OPay Signature Vibrant Teal Green
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        onPressed: !hasAccount ? null : () {
                          // Native Share sheet interface initialization track goes here
                        },
                        child: const Text('Share Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // --- Custom Layout Separator Line ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('OR', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
              ],
            ),
          ),

          // ====================================================================
          // 💵 MODULAR METHOD PAYMENT ROUTABLE CARDS
          // ====================================================================
          _buildPaymentMethodCard(
            title: 'Cash Deposit',
            subtitle: 'Fund your account with nearby merchants',
            icon: Icons.local_atm_outlined,
            onTap: () => context.push('${AppRouter.dashboard}/cash-deposit'),
          ),
          _buildPaymentMethodCard(
            title: 'Top-up with Card/Account',
            subtitle: 'Add money directly from your bank card or account',
            icon: Icons.credit_card_rounded,
            onTap: () => context.push('${AppRouter.dashboard}/card-topup'),
          ),
          _buildPaymentMethodCard(
            title: 'Bank USSD',
            subtitle: "With other banks' USSD code setup links",
            icon: Icons.phone_android_rounded,
            onTap: () => context.push('${AppRouter.dashboard}/bank-ussd'),
          ),
          _buildPaymentMethodCard(
            title: 'Scan my QR Code',
            subtitle: 'Show QR code to any secure ecosystem peer user',
            icon: Icons.qr_code_scanner_rounded,
            onTap: () => context.push('${AppRouter.dashboard}/scan-qr'),
          ),
        ],
      ),
    );
  }

  // Universal custom card wrapper logic
  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
          ),
          child: Row(
            children: [
              _buildActionIconContainer(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11.5)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIconContainer(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.dev1Silver.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.dev1Silver, size: 22),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: 180,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: Colors.white10,
      ),
    );
  }
}