import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto_withdrawal_bloc.dart';
import '../bloc/crypto_withdrawal_event.dart';
import '../bloc/crypto_withdrawal_state.dart';
import '../../data/datasources/crypto_api_client.dart';

class CryptoWithdrawalScreen extends StatefulWidget {
  const CryptoWithdrawalScreen({super.key});

  @override
  State<CryptoWithdrawalScreen> createState() => _CryptoWithdrawalScreenState();
}

class _CryptoWithdrawalScreenState extends State<CryptoWithdrawalScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedNetwork = 'usdttrx'; // Default network to TRC20 (Low fees)
  double _platformFee = 0.0;
  double _netPayout = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateFees);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Calculates your mentor's 1% platform fee algorithm dynamically in the UI
  void _calculateFees() {
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _platformFee = enteredAmount * 0.01; // 1% global processing fee
      _netPayout = enteredAmount - _platformFee;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CryptoWithdrawalBloc(apiClient: CryptoApiClient()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0C), // Matches your dark dashboard theme
        appBar: AppBar(
          title: const Text('Withdraw Crypto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF121214),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocConsumer<CryptoWithdrawalBloc, CryptoWithdrawalState>(
          listener: (context, state) {
            if (state is CryptoWithdrawalSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Withdrawal Executed! ID: ${state.withdrawalDetails.id}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context); // Go back to dashboard on success
            } else if (state is CryptoWithdrawalError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is CryptoWithdrawalLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Withdraw funds directly from your Web3 Smart Wallet out to any public decentralized blockchain network.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // 1. ADDRESS INPUT FIELD
                  const Text('Destination Wallet Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Paste public address (e.g. 0x... or Tx...)',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF121214),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. NETWORK SELECTION toggles
                  const Text('Select Blockchain Network', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('TRC20 (TRON)')),
                          selected: _selectedNetwork == 'usdttrx',
                          selectedColor: Colors.orangeAccent.withValues(alpha: 0.2),
                          checkmarkColor: Colors.orangeAccent,
                          labelStyle: TextStyle(color: _selectedNetwork == 'usdttrx' ? Colors.orangeAccent : Colors.grey),
                          onSelected: (bool value) {
                            if (value) setState(() => _selectedNetwork = 'usdttrx');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('BEP20 (BSC)')),
                          selected: _selectedNetwork == 'usdtbsc',
                          selectedColor: Colors.orangeAccent.withValues(alpha: 0.2),
                          checkmarkColor: Colors.orangeAccent,
                          labelStyle: TextStyle(color: _selectedNetwork == 'usdtbsc' ? Colors.orangeAccent : Colors.grey),
                          onSelected: (bool value) {
                            if (value) setState(() => _selectedNetwork = 'usdtbsc');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. AMOUNT INPUT FIELD
                  const Text('Amount to Withdraw (USD)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: Colors.white),
                      hintText: '0.00',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF121214),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. MENTOR'S ALGORITHM TRANSACTION BREAKDOWN CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121214),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('SaaS Processing Fee (1%)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text('\$${_platformFee.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Net Payout to Wallet', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('\$${_netPayout.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 5. SUBMIT EXECUTION BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final enteredAddress = _addressController.text.trim();
                      final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

                      if (enteredAddress.isEmpty || enteredAmount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill out all form inputs with valid values')),
                        );
                        return;
                      }

                      // Dispatches the transaction straight out via the BLoC manager
                      BlocProvider.of<CryptoWithdrawalBloc>(context).add(
                        ExecuteCryptoWithdrawal(
                          destinationAddress: enteredAddress,
                          networkCurrency: _selectedNetwork,
                          amount: enteredAmount,
                        ),
                      );
                    },
                    child: const Text('Confirm & Send Out', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}