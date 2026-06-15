import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto_swap_bloc.dart';
import '../bloc/crypto_swap_event.dart';
import '../bloc/crypto_swap_state.dart';

class CryptoSwapScreen extends StatefulWidget {
  const CryptoSwapScreen({super.key});

  @override
  State<CryptoSwapScreen> createState() => _CryptoSwapScreenState();
}

class _CryptoSwapScreenState extends State<CryptoSwapScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CryptoSwapBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0C),
        appBar: AppBar(
          title: const Text('Swap Balances', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF121214),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocConsumer<CryptoSwapBloc, CryptoSwapState>(
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Swap executed successfully! Balances updated.'), backgroundColor: Colors.green),
              );
              _amountController.clear();
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Instantly exchange value between your traditional Fiat core assets and your Web3 Smart Wallets securely.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 1. "FROM" SOURCE MODULE ROW CARD
                  // ==========================================
                  _buildInputBox(
                    context,
                    title: 'From (Source Asset)',
                    assetLabel: state.isFiatToCrypto ? 'Fiat Wallet (USD)' : 'Smart Wallet (USDT)',
                    icon: state.isFiatToCrypto ? Icons.account_balance : Icons.currency_bitcoin,
                    iconColor: state.isFiatToCrypto ? Colors.blueAccent : const Color(0xFF50C878),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        context.read<CryptoSwapBloc>().add(CalculateSwapAmounts(inputAmount: parsed));
                      },
                    ),
                  ),

                  // ==========================================
                  // DIRECTION DIRECTION SWITCHER TOGGLE ICON BUTTON
                  // ==========================================
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _amountController.clear();
                        context.read<CryptoSwapBloc>().add(ToggleSwapDirection());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Color(0xFF1E1E22), shape: BoxShape.circle),
                        child: const Icon(Icons.swap_vert, color: Colors.purpleAccent, size: 26),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 2. "TO" TARGET MODULE ROW CARD
                  // ==========================================
                  _buildInputBox(
                    context,
                    title: 'To (Destination Target Asset)',
                    assetLabel: state.isFiatToCrypto ? 'Smart Wallet (USDT)' : 'Fiat Wallet (USD)',
                    icon: state.isFiatToCrypto ? Icons.currency_bitcoin : Icons.account_balance,
                    iconColor: state.isFiatToCrypto ? const Color(0xFF50C878) : Colors.blueAccent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        state.outputAmount > 0 ? state.outputAmount.toStringAsFixed(4) : '0.00',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 3. MENTOR'S ALGORITHMIC PLATFORM FEE BREAKDOWN
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121214),
                      borderRadius: BorderRadius.circular(12),
                      // ignore: deprecated_member_use
                      border: Border.all(color: Colors.grey.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Exchange SaaS Fee (1%)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(
                          '\$${state.platformFee.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // EXECUTE CONVERSION BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: state.inputAmount <= 0
                        ? null
                        : () {
                            context.read<CryptoSwapBloc>().add(
                                  ExecuteSwapTransaction(
                                    targetGrossAmount: state.inputAmount,
                                    isFiatToCrypto: state.isFiatToCrypto,
                                  ),
                                );
                          },
                    child: const Text(
                      'Confirm Exchange Swap',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputBox(
    BuildContext context, {
    required String title,
    required String assetLabel,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: child),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF1E1E22), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 16),
                    const SizedBox(width: 6),
                    Text(assetLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}