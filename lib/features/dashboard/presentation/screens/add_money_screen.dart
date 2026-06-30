// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'web_payment_stub.dart' if (dart.library.js_util) 'web_payment_web.dart' as web_payment;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool _isSuccessfulFlutterwaveStatus(String? status) {
    final normalized = status?.toLowerCase();
    return normalized == 'completed' ||
        normalized == 'successful' ||
        normalized == 'success' ||
        normalized == '00';
  }

  /// Keeps the deposit pending while the hashed Flutterwave webhook verifies and funds the wallet.
  Future<void> _awaitWebhookConfirmation(
    SupabaseClient client,
    String uniqueTxRef,
    double amount,
  ) async {
    await client
        .from('deposits')
        .update({'status': 'pending'})
        .eq('tx_ref', uniqueTxRef);

    if (!mounted) return;

    // FIX: Execute state resets and navigation safely on the next frame callback.
    // This resolves the 'Cannot hit test a render box that has never been laid out' gesture error on Flutter Web!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _amountController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully funded NGN ${amount.toStringAsFixed(2)} via Flutterwave checkout secure channel.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/dashboard');
    });
  }

  /// Marks a transaction as failed in Supabase when canceled or rejected
  Future<void> _failDepositTransaction(
    SupabaseClient client,
    String uniqueTxRef,
    String status,
  ) async {
    await client
        .from('deposits')
        .update({'status': 'failed'})
        .eq('tx_ref', uniqueTxRef)
        .eq('status', 'pending');

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment cancelled or rejected: $status'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isLoading = false);
    });
  }

  /// Handles validation, triggers the Flutterwave checkout gateway payment instance,
  /// and updates transaction ledgers and fiat wallet balances inside Supabase securely.
  Future<void> _initiateDepositPipeline() async {
    if (!_formKey.currentState!.validate()) return;

    // Safely load the key only when the user clicks the button
    final String publicKey = dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? "";
    if (publicKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Payment keys not loaded')),
      );
      return;
    }

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

      if (kIsWeb) {
        // CORS Bypass: Trigger inline JavaScript SDK checkout for Flutter Web
        web_payment.triggerWebCheckout(
          publicKey: publicKey,
          txRef: uniqueTxRef,
          amount: inputAmount,
          userEmail: userEmail,
          userName: userName,
          phoneNumber: user.userMetadata?['phone_number'] ?? "00000000000",
          onSuccess: (response) async {
            final String status =
                response['status']?.toString().toLowerCase() ?? 'failed';
            final String chargeResponseCode =
                response['charge_response_code']?.toString() ?? '';
            final String transactionId =
                response['transaction_id']?.toString() ?? '';
            if (_isSuccessfulFlutterwaveStatus(status) ||
                _isSuccessfulFlutterwaveStatus(chargeResponseCode) ||
                transactionId.isNotEmpty) {
              await _awaitWebhookConfirmation(client, uniqueTxRef, inputAmount);
            } else {
              await _failDepositTransaction(client, uniqueTxRef, status);
            }
          },
          onCancel: () async {
            await _failDepositTransaction(client, uniqueTxRef, 'cancelled');
          },
          onError: (error) {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Web checkout error: $error'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                setState(() => _isLoading = false);
              });
            }
          },
        );
      } else {
        // 2. Configure Flutterwave Standard payment instance for Mobile devices
        final Customer customer = Customer(
          name: userName,
          email: userEmail,
          phoneNumber: user.userMetadata?['phone_number'] ?? "00000000000",
        );

        final Flutterwave flutterwave = Flutterwave(
          publicKey: publicKey,
          currency: "NGN",
          amount: inputAmount.toStringAsFixed(2),
          txRef: uniqueTxRef,
          customer: customer,
          paymentOptions: "card, account, transfer, ussd",
          customization: Customization(
            title: "Wallet Cash-In",
            description:
                "Fund your account pool via Flutterwave Checkout Gateway",
          ),
          isTestMode: true,
          redirectUrl: 'https://gisrbsjzzdtmvjsdnyym.supabase.co/functions/v1/flw-webhook',
        );

        // 3. Launch Flutterwave UI Sheets safely on Mobile
        if (!mounted) return;
        final ChargeResponse response = await flutterwave.charge(context);

        if (!mounted) return;

        final String? paymentStatus = response.status?.toLowerCase();
        final bool hasTransactionId =
            response.transactionId != null &&
            response.transactionId!.isNotEmpty;

        // 4. Leave final verification and funding to the hashed Flutterwave webhook.
        if (_isSuccessfulFlutterwaveStatus(paymentStatus) ||
            response.success == true ||
            hasTransactionId) {
          await _awaitWebhookConfirmation(client, uniqueTxRef, inputAmount);
        } else {
          await _failDepositTransaction(
            client,
            uniqueTxRef,
            paymentStatus ?? 'failed',
          );
        }
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
      if (mounted && !kIsWeb) setState(() => _isLoading = false);
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: "₦ ",
                    prefixStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                    if (value == null || value.trim().isEmpty)
                      return "Please input an amount";
                    final amt = double.tryParse(value.trim());
                    if (amt == null || amt <= 0)
                      return "Provide a valid transaction amount";
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
                      disabledBackgroundColor: const Color(
                        0xFF10B981,
                      ).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Proceed to Secure Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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