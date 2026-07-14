// ignore_for_file: unused_field, unused_element, unused_import, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  RealtimeChannel? _depositSubscription;

  @override
  void dispose() {
    _amountController.dispose();
    _cleanupSubscription();
    super.dispose();
  }

  void _cleanupSubscription() {
    if (_depositSubscription != null) {
      Supabase.instance.client.removeChannel(_depositSubscription!);
      _depositSubscription = null;
    }
  }

  bool _isSuccessfulFlutterwaveStatus(String? status) {
    final normalized = status?.toLowerCase();
    return ['completed', 'successful', 'success', '00'].contains(normalized);
  }

  Future<void> _awaitWebhookConfirmation(String uniqueTxRef) async {
    _cleanupSubscription();
    
    _depositSubscription = Supabase.instance.client
        .channel('public:deposits:tx_ref=eq.$uniqueTxRef')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'deposits',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'tx_ref', value: uniqueTxRef),
          callback: (payload) {
            final String currentStatus = payload.newRecord['status'] ?? 'pending';
            
            if (_isSuccessfulFlutterwaveStatus(currentStatus)) {
              _cleanupSubscription();
              if (!mounted) return;
              
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Deposit successful!'), 
                backgroundColor: Colors.green
              ));
              context.go('/dashboard');
            }
          },
        )
        .subscribe();
  }

  Future<void> _initiateDepositPipeline() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) throw Exception("User session expired");

      final double inputAmount = double.parse(_amountController.text.trim());
      final String uniqueTxRef = "TX-${DateTime.now().millisecondsSinceEpoch}";

      await client.from('deposits').insert({
        'user_id': user.id,
        'amount': inputAmount,
        'tx_ref': uniqueTxRef,
        'status': 'pending',
      });

      await _awaitWebhookConfirmation(uniqueTxRef);

      if (kIsWeb) {
        final response = await client.functions.invoke('flw-webhook', body: {
          'action': 'initialize_payment',
          'tx_ref': uniqueTxRef,
          'amount': inputAmount.toString(),
        });
        final checkoutUrl = response.data['checkout_url'];
        await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      } else {
        // Native Mobile Implementation
        final Flutterwave flutterwave = Flutterwave(
          
          publicKey: Environment.flutterwavePublicKey, // Ensure this exists in your env file
          currency: "NGN",
          redirectUrl: "https://your-redirect-url.com", // Replace with your actual redirect URL
          txRef: uniqueTxRef,
          amount: inputAmount.toString(),
          customer: Customer(email: user.email ?? "user@example.com"),
          paymentOptions: "card, banktransfer, ussd",
          customization: Customization(title: "Add Money"),
          isTestMode: true, // Set to false for production
        );

        final ChargeResponse response = await flutterwave.charge(context);
        if (response.success == true) {
          // Keep _isLoading true while waiting for webhook
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${response.status}')));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ENTER DEPOSIT AMOUNT (NGN)"),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter amount";
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 100) return "Minimum amount is ₦100";
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixText: "₦ ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _initiateDepositPipeline,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Proceed to Secure Checkout"),
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