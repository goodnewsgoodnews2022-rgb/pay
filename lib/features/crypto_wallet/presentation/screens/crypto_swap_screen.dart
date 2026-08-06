// ignore_for_file: prefer_final_fields, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class CryptoSwapScreen extends StatefulWidget {
  const CryptoSwapScreen({super.key});

  @override
  State<CryptoSwapScreen> createState() => _CryptoSwapScreenState();
}

class _CryptoSwapScreenState extends State<CryptoSwapScreen> {
  final _amountController = TextEditingController();

  final List<String> _cryptoCurrencies = ['USDT', 'BTC', 'ETH', 'SOL'];
  final List<String> _fiatCurrencies = ['NGN'];

  String _selectedCrypto = 'USDT';
  String _selectedFiat = 'NGN';
  
  double _inputCryptoAmount = 0.0;
  double _convertedFiatAmount = 0.0;
  double _platformFee = 0.0;
  bool _isLoading = false;

  double _getExchangeRate(String crypto) {
    switch (crypto) {
      case 'BTC':
        return 95000000.0;
      case 'ETH':
        return 3800000.0;
      case 'SOL':
        return 180000.0;
      case 'USDT':
      default:
        return 1500.0;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateSwap(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    setState(() {
      _inputCryptoAmount = parsed;
      final rate = _getExchangeRate(_selectedCrypto);
      final grossNaira = parsed * rate;
      _platformFee = grossNaira * 0.01;
      _convertedFiatAmount = grossNaira - _platformFee;
    });
  }

  Future<void> _executeLocalSwap() async {
    if (_inputCryptoAmount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception("No authenticated user found.");
      }

      final walletResponse = await client
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final walletBalanceResponse = await client
          .from('wallet_balances')
          .select()
          .eq('user_identifier', userId)
          .maybeSingle();

      double currentCryptoBalance = walletResponse != null ? (walletResponse['crypto_balance'] ?? 0.0).toDouble() : 0.0;
      double currentNairaBalance = walletBalanceResponse != null ? (walletBalanceResponse['naira_balance'] ?? 0.0).toDouble() : 0.0;

      if (currentCryptoBalance < _inputCryptoAmount) {
        _showErrorSnackbar('Insufficient crypto balance in your wallet.');
        setState(() => _isLoading = false);
        return;
      }

      double newCryptoBalance = currentCryptoBalance - _inputCryptoAmount;
      double newNairaBalance = currentNairaBalance + _convertedFiatAmount;

      if (walletResponse != null) {
        await client
            .from('wallets')
            .update({'crypto_balance': newCryptoBalance})
            .eq('user_id', userId);
      } else {
        await client.from('wallets').insert({
          'user_id': userId,
          'crypto_balance': newCryptoBalance,
        });
      }

      if (walletBalanceResponse != null) {
        await client
            .from('wallet_balances')
            .update({'naira_balance': newNairaBalance})
            .eq('user_identifier', userId);
      } else {
        await client.from('wallet_balances').insert({
          'user_identifier': userId,
          'naira_balance': newNairaBalance,
        });
      }

      await client.from('transactions').insert({
        'user_identifier': userId,
        'amount': _inputCryptoAmount,
        'type': 'swap',
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
            content: Text('success'),
          ),
        );
        _amountController.clear();
        
        // Safe navigation redirect back to dashboard
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Swap Failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    const accentColor = Color(0xFF10B981);
    final primaryButtonColor = isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6);
    final elementBgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final secondaryLabelColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Crypto to Naira Swap',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF111622) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryButtonColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Swap your digital assets directly into your Naira balance instantly.',
                    style: TextStyle(color: secondaryLabelColor, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  _buildInputBox(
                    context,
                    title: 'From (Source Crypto Asset)',
                    selectedValue: _selectedCrypto,
                    options: _cryptoCurrencies,
                    icon: Icons.currency_bitcoin,
                    iconColor: accentColor,
                    textColor: textColor,
                    cardColor: cardColor,
                    elementBgColor: elementBgColor,
                    secondaryLabelColor: secondaryLabelColor,
                    onAssetChanged: (newValue) {
                      setState(() {
                        _selectedCrypto = newValue;
                        _calculateSwap(_amountController.text);
                      });
                    },
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      onChanged: _calculateSwap,
                    ),
                  ),

                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: elementBgColor,
                        shape: BoxShape.circle,
                        border: isDark ? null : Border.all(color: Colors.grey[300]!),
                      ),
                      child: Icon(Icons.arrow_downward_rounded, color: primaryButtonColor, size: 22),
                    ),
                  ),

                  _buildInputBox(
                    context,
                    title: 'To (Destination Fiat Wallet)',
                    selectedValue: _selectedFiat,
                    options: _fiatCurrencies,
                    icon: Icons.account_balance,
                    iconColor: Colors.blueAccent,
                    textColor: textColor,
                    cardColor: cardColor,
                    elementBgColor: elementBgColor,
                    secondaryLabelColor: secondaryLabelColor,
                    onAssetChanged: (_) {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        _convertedFiatAmount > 0 ? '${_convertedFiatAmount.toStringAsFixed(2)} NGN' : '0.00 NGN',
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.05 : 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Exchange Fee (1%)', style: TextStyle(color: secondaryLabelColor, fontSize: 13)),
                        Text(
                          '${_platformFee.toStringAsFixed(2)} NGN',
                          style: TextStyle(color: primaryButtonColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _inputCryptoAmount <= 0 ? null : _executeLocalSwap,
                    child: const Text(
                      'Confirm Crypto-to-Naira Swap',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputBox(
    BuildContext context, {
    required String title,
    required String selectedValue,
    required List<String> options,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color cardColor,
    required Color elementBgColor,
    required Color? secondaryLabelColor,
    required Function(String) onAssetChanged,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(color: secondaryLabelColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: child),
              Container(
                width: 130,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: elementBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF111622) : Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: secondaryLabelColor, size: 20),
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: iconColor, size: 13),
                            const SizedBox(width: 4),
                            Text(value, style: TextStyle(color: textColor)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onAssetChanged(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}