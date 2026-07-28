// ignore_for_file: unused_local_variable, unused_element, unused_import, duplicate_import, use_build_context_synchronously, curly_braces_in_flow_control_structures
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutterwave_standard/models/requests/customizations.dart';

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
    final normalized = (status ?? '').toLowerCase().trim();
    // Your DB enum allows: pending, completed, failed, successful, success
    // Accept all successful-ish values.
    return [
      'completed',
      'successful',
      'success',
    ].contains(normalized);
  }

  Future<void> _awaitWebhookConfirmation(String uniqueTxRef) async {
    _cleanupSubscription();

    final completer = Completer<void>();

    _depositSubscription = Supabase.instance.client
        .channel('public:deposits:tx_ref=eq.$uniqueTxRef')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'deposits',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tx_ref',
            value: uniqueTxRef,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            final String currentStatus =
                (newRecord['status'] ?? 'pending').toString();

            if (_isSuccessfulFlutterwaveStatus(currentStatus)) {
              _cleanupSubscription();
              if (!mounted) return;

              if (!completer.isCompleted) completer.complete();
            }
          },
        )
        .subscribe();

    // Safety timeout (so you can see errors in UI)
    await completer.future.timeout(const Duration(seconds: 90));
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
      final String userEmail = user.email ?? 'guest@payfintech.com';
      final String userName = (user.userMetadata?['full_name'] ?? 'Guest User').toString();

      // Insert deposit row first (webhook will update it later)
      await client.from('deposits').insert({
        'user_id': user.id,
        'amount': inputAmount,
        'tx_ref': uniqueTxRef,
        'status': 'pending',
      });

      // Start waiting AFTER inserting
      await _awaitWebhookConfirmation(uniqueTxRef);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deposit successful!',),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/dashboard');

      // On success we stop loading
      setState(() => _isLoading = false);
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _initializeWebPayment({
    required String txRef,
    required double amount,
    required String userId,
    required String customerEmail,
    required String customerName,
  }) async {
    // Calls Edge Function which creates a Flutterwave payment and returns redirect link
    final client = Supabase.instance.client;

    // ⚠️ Set this to your real redirect URL in Environment/config
    const String redirectUrl = Environment.flutterwaveRedirectUrl;

    final response = await client.functions.invoke('flw-webhook', body: {
      'action': 'initialize_payment',
      'tx_ref': txRef,
      'amount': amount,
      'currency': 'NGN',
      'redirect_url': redirectUrl,
      'meta': {
        'user_id': userId,
      },
      'customer': {
        'email': customerEmail,
        'name': customerName,
      },
      'customizations': {
        'title': 'Wallet Funding',
      },
    });

    final data = response.data;

    // Expected structure from your function: { data: { link: "..." } }
    final link = data?['data']?['link'];
    if (link == null) throw Exception("Invalid response: missing redirect link");

    await launchUrl(Uri.parse(link.toString()), mode: LaunchMode.externalApplication);
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
                    onPressed: _isLoading ? null : () async {
                      if (!_formKey.currentState!.validate()) return;

                      // Web flow: you must initialize payment to get the redirect link.
                      // Mobile flow: Flutterwave SDK will create the payment and redirect/handle checkout.
                      // Your current UI calls only _initiateDepositPipeline().
                      // We'll keep the same deposit insert + waiting, but for web we also must initialize.

                      // To keep it simple: call pipeline first (it inserts + waits).
                      // But you also need a payment initiation before webhook can arrive.
                      //
                      // So we do: for web, initialize first, then wait.
                      // For mobile, use Flutterwave charge and let webhook update deposit.
                      final client = Supabase.instance.client;
                      final user = client.auth.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session expired")));
                        return;
                      }

                      final inputAmount = double.parse(_amountController.text.trim());
                      final uniqueTxRef = "TX-${DateTime.now().millisecondsSinceEpoch}";

                      // Insert deposit row
                      setState(() => _isLoading = true);
                      await client.from('deposits').insert({
                        'user_id': user.id,
                        'amount': inputAmount,
                        'tx_ref': uniqueTxRef,
                        'status': 'pending',
                      });

                      // Listen for update
                      final waitTask = _awaitWebhookConfirmation(uniqueTxRef);

                      if (kIsWeb) {
                        await _initializeWebPayment(
                          txRef: uniqueTxRef,
                          amount: inputAmount,
                          userId: user.id,
                          customerEmail: user.email ?? 'guest@payfintech.com',
                          customerName: (user.userMetadata?['full_name'] ?? 'Guest User').toString(),
                        );
                      } else {
                        final Flutterwave flutterwave = Flutterwave(
                          publicKey: Environment.flutterwavePublicKey,
                          currency: "NGN",
                          redirectUrl: Environment.flutterwaveRedirectUrl,
                          txRef: uniqueTxRef,
                          amount: inputAmount.toString(),
                          customer: Customer(email: user.email ?? 'guest@payfintech.com'),
                          paymentOptions: "card, banktransfer, ussd",
                          customization: Customization(title: "Wallet Funding"),
                          // ⚠️ remove test mode in production
                          isTestMode: false,
                        );

                        final ChargeResponse response = await flutterwave.charge(context);
                        if (response.success != true) {
                          _cleanupSubscription();
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment failed: ${response.status}')),
                          );
                          return;
                        }
                      }

                      // Wait webhook update
                      await waitTask;

                      if (!mounted) return;

                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Deposit successful!'), backgroundColor: Colors.green),
                      );
                      context.go('/dashboard');
                    },
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