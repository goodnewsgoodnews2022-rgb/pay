// lib/features/dashboard/presentation/screens/currency_holding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintech/features/dashboard/providers/wallet_provider.dart';

// Provider to get the stored exchange rate from your database
final exchangeRateProvider = FutureProvider<double>((ref) async {
  final response = await Supabase.instance.client
      .from('exchange_rates')
      .select('rate')
      .eq('id', 1)
      .maybeSingle();
  return (response?['rate'] as num?)?.toDouble() ?? 1500.0;
});

class CurrencyHoldingScreen extends ConsumerWidget {
  const CurrencyHoldingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsyncValue = ref.watch(fiatWalletStreamProvider);
    final rateAsyncValue = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Currency Holdings")),
      body: walletAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (walletData) {
          final double ngn = (walletData?['ngn_balance'] ?? 0.0).toDouble();
          return rateAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Conversion unavailable: $err")),
            data: (rate) {
              final double usd = ngn / rate;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCurrencyCard("Nigerian Naira", "₦", ngn),
                  const SizedBox(height: 16),
                  _buildCurrencyCard("US Dollar", "\$", usd),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrencyCard(String name, String symbol, double amount) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Text("$symbol${amount.toStringAsFixed(2)}", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}