// lib/features/settings/transaction_limit.dart

import 'package:flutter/material.dart';

class TransactionLimitGuard extends StatefulWidget {
  const TransactionLimitGuard({super.key});

  @override
  State<TransactionLimitGuard> createState() => _TransactionLimitGuardState();
}

class _TransactionLimitGuardState extends State<TransactionLimitGuard> {
  double _dailyLimit = 250000;
  double _perTransactionLimit = 50000;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction Limit Guard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Secure your funds by setting caps on your account outflow amounts.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Slider Item 1: Daily Accumulative Cap
          Card(
            color: cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daily Outflow Cap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        '₦${_dailyLimit.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider.adaptive(
                    value: _dailyLimit,
                    min: 50000,
                    max: 1000000,
                    divisions: 19,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (value) => setState(() => _dailyLimit = value),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₦50k', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('Max ₦1M (Tier 2)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Slider Item 2: Per Single Transaction Cap
          Card(
            color: cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Single Transfer Cap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        '₦${_perTransactionLimit.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider.adaptive(
                    value: _perTransactionLimit,
                    min: 10000,
                    max: 200000,
                    divisions: 19,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (value) => setState(() => _perTransactionLimit = value),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₦10k', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('Max ₦200k per push', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Save Parameters Action Button
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account transaction limits enforced successfully'),
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
            child: const Text('Enforce Guard Limits', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}