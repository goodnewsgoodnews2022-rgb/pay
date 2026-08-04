// lib/features/settings/transaction_limit.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionLimitGuard extends StatefulWidget {
  const TransactionLimitGuard({super.key});

  @override
  State<TransactionLimitGuard> createState() => _TransactionLimitGuardState();
}

class _TransactionLimitGuardState extends State<TransactionLimitGuard> {
  bool _isLoading = true;

  // Account tier based limits (Read-only view for the user)
  int _tierLevel = 2;
  double _dailyLimit = 1000000;
  double _singleLimit = 200000;
  double _dailyUsed = 350000; // Example tracked usage for real-time progress visualization

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchAccountLimits();
  }

  Future<void> _fetchAccountLimits() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Fetching from user profile / settings table where app-defined limits are stored
      final response = await _supabase
          .from('user_settings')
          .select('tier_level, daily_limit, single_limit, daily_used')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _tierLevel = (response['tier_level'] as num?)?.toInt() ?? 2;
          _dailyLimit = (response['daily_limit'] as num?)?.toDouble() ?? 1000000;
          _singleLimit = (response['single_limit'] as num?)?.toDouble() ?? 200000;
          _dailyUsed = (response['daily_used'] as num?)?.toDouble() ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast('Failed to load live account limits', isError: true);
      }
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

  String _formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100];
    const accentColor = Color(0xFF10B981);

    final double dailyProgress = (_dailyUsed / _dailyLimit).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction Limits & Tier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Tier Status Banner card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor.withOpacity(0.2), accentColor.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: accentColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Tier $_tierLevel Account',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Limits are regulated based on your KYC verification level.',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _showToast('Upgrade requirements available in KYC section.');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: accentColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Upgrade', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Utilization Card
                Card(
                  color: cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Today's Outflow Used", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                            Text(
                              '${(dailyProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatCurrency(_dailyUsed),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'monospace'),
                            ),
                            Text(
                              'Cap: ${_formatCurrency(_dailyLimit)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: dailyProgress,
                            minHeight: 8,
                            backgroundColor: accentColor.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Limit Item 1: Daily Outflow Cap (App Enforced)
                Card(
                  color: cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.today_rounded, color: accentColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Maximum Daily Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(
                                'Total cumulative outflow allowed per 24 hours.',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(_dailyLimit),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontFamily: 'monospace', fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Limit Item 2: Single Transfer Cap (App Enforced)
                Card(
                  color: cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.send_rounded, color: accentColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Single Transaction Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(
                                'Maximum amount permitted per single transfer push.',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(_singleLimit),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontFamily: 'monospace', fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}