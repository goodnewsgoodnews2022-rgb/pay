// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 📂 Flutterwave Testing Credentials
  static const String _flwTestPublicKey = "FLWPUBK_TEST-ba6fd099c1d6d6269da9852637b0563c-X";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Handles validation, triggers the Flutterwave checkout gateway payment instance,
  /// and updates transaction ledgers and fiat wallet balances inside Supabase securely.
  Future<void> _initiateDepositPipeline() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception("User session expired");

      final double inputAmount = double.parse(_amountController.text.trim());
      final String uniqueTxRef =
          "TXREF-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 5)}";
      final String userEmail = user.email ?? "${user.id}@smartwallet.com";
      final String userName =
          user.userMetadata?['full_name'] ?? 'Smart Wallet Customer';

      // 1. Log transaction safely into 'deposits' table in a 'pending' state
      final Map<String, dynamic> depositPayload = {
        'user_id': user.id,
        'amount': inputAmount,
        'currency': 'NGN',
        'tx_ref': uniqueTxRef,
        'status': 'pending',
      };
     await client.from('deposits').insert(depositPayload);

      // 2. Configure Flutterwave Standard payment instance
      final Customer customer = Customer(
        name: userName,
        email: userEmail,
        phoneNumber: user.userMetadata?['phone_number'] ?? "00000000000",
      );

      final Flutterwave flutterwave = Flutterwave(
        publicKey: _flwTestPublicKey,
        currency: "NGN",
        amount: inputAmount.toStringAsFixed(2),
        txRef: uniqueTxRef,
        customer: customer,
        paymentOptions: "card, account, transfer, ussd", 
        customization: Customization(
          title: "Wallet Cash-In",
          description: "Fund your account pool via Flutterwave Checkout Gateway",
        ),
        isTestMode: true,
        redirectUrl: 'https://webhook.site',
      );

      // 3. Launch Flutterwave UI Sheets safely
      if (!mounted) return; 
      final ChargeResponse response = await flutterwave.charge(context);

      if (!mounted) return;

      final String? paymentStatus = response.status?.toLowerCase();

      // 4. Handle structural payment evaluation states
      if (paymentStatus == "success" || paymentStatus == "successful" || response.success == true) {
        
        // A. Update local ledger transaction tracking status to success
        await client
            .from('deposits')
            .update({'status': 'success'})
            .eq('tx_ref', uniqueTxRef);

        // B. Fetch the single wallet row total to recalculate balance safely
        final walletFetch = await client
            .from('fiat_wallets')
            .select('ngn_balance')
            .eq('user_id', user.id)
            .maybeSingle();

        double calculatedCurrentBalance = 0.0;
        bool walletExists = false;

        if (walletFetch != null) {
          walletExists = true;
          final dynamic rawBalance = walletFetch['ngn_balance'];
          calculatedCurrentBalance = rawBalance != null 
              ? double.tryParse(rawBalance.toString()) ?? 0.0 
              : 0.0;
        }
            
        final double targetedNewBalance = calculatedCurrentBalance + inputAmount;

        // C. Update total holding pool balance (Omitting timestamp fields to avoid constraint type parsing bugs)
        if (walletExists) {
          await client
              .from('fiat_wallets')
              .update({'ngn_balance': targetedNewBalance})
              .eq('user_id', user.id);
        } else {
          await client
              .from('fiat_wallets')
              .insert({
                'user_id': user.id,
                 'currency': 'NGN',
                'ngn_balance': targetedNewBalance,
              });
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet funded successfully! Dashboard balances updated.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/dashboard'); 
      } else {
        // Mark individual history log row as failed if user cancels
        await client
            .from('deposits')
            .update({'status': 'failed'})
            .eq('tx_ref', uniqueTxRef);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment cancelled or rejected: ${response.status}'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction setup failed: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Money',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ENTER DEPOSIT AMOUNT (NGN)",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  enabled: !_isLoading, 
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: "₦ ",
                    prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    hintText: "0.00",
                    filled: true,
                    fillColor: isDark ? Colors.grey[950] : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Please input an amount";
                    final amt = double.tryParse(value.trim());
                    if (amt == null || amt <= 0) return "Provide a valid transaction amount";
                    if (amt < 100) return "Minimum deposit amount is ₦100.00";
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _initiateDepositPipeline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF10B981).withOpacity(0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            "Proceed to Secure Checkout",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}