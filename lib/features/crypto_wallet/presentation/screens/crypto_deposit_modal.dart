import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto_wallet_bloc.dart';
import '../bloc/crypto_wallet_event.dart';
import '../bloc/crypto_wallet_state.dart';
import '../../data/datasources/crypto_api_client.dart';

class CryptoDepositModal extends StatefulWidget {
  const CryptoDepositModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => CryptoWalletBloc(apiClient: CryptoApiClient()),
        child: const CryptoDepositModal(),
      ),
    );
  }

  @override
  State<CryptoDepositModal> createState() => _CryptoDepositModalState();
}

class _CryptoDepositModalState extends State<CryptoDepositModal> {
  final _amountController = TextEditingController();
  String _selectedNetwork = 'usdttrx'; // Default network to TRC20

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose(); // ✅ Fixed: Correct call to super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocConsumer<CryptoWalletBloc, CryptoWalletState>(
        listener: (context, state) {
          if (state is CryptoWalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildModalContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildModalContent(BuildContext context, CryptoWalletState state) {
    // 1. LOADING STATE
    if (state is CryptoWalletLoading) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(color: Colors.green), // ✅ Fixed: Replaced 'emerald' with standard 'green'
        ),
      );
    }

    // 2. SUCCESS GENERATED STATE
    if (state is CryptoWalletAddressGenerated) {
      final details = state.paymentDetails;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send ${details.payCurrency.toUpperCase()}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Copy the deposit address below to fund your wallet. Your balance will update automatically once verified on the chain.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    details.payAddress,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.green), // ✅ Fixed: Replaced 'emerald' with 'green'
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: details.payAddress));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    // 3. INITIAL INITIAL INPUT FORM STATE
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Deposit Crypto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 12),
        const Text('Enter USD Amount equivalent:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: '0.00',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2), // ✅ Fixed: Replaced 'emerald' with 'green'
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Select Network Chain:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('TRC20 (TRON)')),
                selected: _selectedNetwork == 'usdttrx',
                onSelected: (bool value) { // ✅ Fixed: Repaired broken inline syntax closure
                  if (value) setState(() => _selectedNetwork = 'usdttrx');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('BEP20 (BSC)')),
                selected: _selectedNetwork == 'usdtbsc',
                onSelected: (bool value) { // ✅ Fixed: Repaired broken inline syntax closure
                  if (value) setState(() => _selectedNetwork = 'usdtbsc');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // ✅ Fixed: Replaced 'emerald' with 'green'
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final parsedAmount = double.tryParse(_amountController.text) ?? 0.0;
            if (parsedAmount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid deposit amount')),
              );
              return;
            }
            context.read<CryptoWalletBloc>().add(
                  GenerateDepositAddress(amount: parsedAmount, networkCurrency: _selectedNetwork),
                );
          },
          child: const Text('Generate Secure Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}