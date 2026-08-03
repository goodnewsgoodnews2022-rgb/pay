// lib/features/dashboard/presentation/screens/currency_holding_screen.dart

// ignore_for_file: unused_local_variable, unused_element_parameter, prefer_const_constructors, unused_element, unused_field, implementation_imports, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class CurrencyHoldingScreen extends ConsumerStatefulWidget {
  const CurrencyHoldingScreen({super.key});

  @override
  ConsumerState<CurrencyHoldingScreen> createState() => _CurrencyHoldingScreenState();
}

class _CurrencyHoldingScreenState extends ConsumerState<CurrencyHoldingScreen> {
  double _ngnBalance = 0.0;
  bool _isLoadingBalances = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _fetchSupabaseWalletBalance();
  }

  // ============================================
  // 📊 FETCH NGN BALANCE STRICTLY PER LOGGED-IN USER ID
  // ============================================
  Future<void> _fetchSupabaseWalletBalance() async {
    if (_isLoadingBalances) return;

    setState(() {
      _isLoadingBalances = true;
      _lastError = null;
    });

    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      debugPrint('Current Auth User ID: $currentUserId');

      if (currentUserId == null || currentUserId.isEmpty) {
        if (mounted) {
          setState(() {
            _lastError = 'No authenticated user found. Please log in again.';
            _ngnBalance = 0.0;
          });
        }
        return;
      }

      final supabase = Supabase.instance.client;
      
      // Strictly query by user_identifier matching the authenticated user ID
      final response = await supabase
          .from('wallet_balances')
          .select('naira_balance')
          .eq('user_identifier', currentUserId)
          .maybeSingle();

      debugPrint('Supabase wallet response for user $currentUserId: $response');

      if (response != null && response['naira_balance'] != null) {
        final balance = (response['naira_balance'] as num).toDouble();
        if (mounted) {
          setState(() {
            _ngnBalance = balance;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _ngnBalance = 0.0;
            _lastError = 'No wallet balance record found for this user profile.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = 'Failed to load balance: $e';
        });
      }
      debugPrint('Error fetching wallet balance: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBalances = false;
        });
      }
    }
  }

  // ============================================
  // 🔄 MANUAL REFRESH
  // ============================================
  Future<void> _manualRefresh() async {
    await _fetchSupabaseWalletBalance();
    if (mounted && _lastError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Balances refreshed successfully'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rateAsyncValue = ref.watch(exchangeRateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Holdings"),
        actions: [
          IconButton(
            icon: Icon(_isLoadingBalances ? Icons.sync : Icons.refresh_rounded),
            onPressed: _isLoadingBalances ? null : _manualRefresh,
          ),
        ],
      ),
      body: rateAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Conversion unavailable: $err")),
        data: (rate) {
          final double usd = _ngnBalance / (rate > 0 ? rate : 1500.0);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_lastError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _lastError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              _buildCurrencyCard("Nigerian Naira", "₦", _ngnBalance, isDark),
              const SizedBox(height: 16),
              _buildCurrencyCard("US Dollar", "\$", usd, isDark),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Last updated: ${DateTime.now().toLocal().toString().split('.').first}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrencyCard(String name, String symbol, double amount, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          trailing: Text(
            "$symbol${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}