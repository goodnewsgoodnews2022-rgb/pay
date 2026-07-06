// ignore_for_file: unused_import, use_build_context_synchronously, unused_local_variable, deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:convert'; // 🚀 Added for processing backend JSON payload
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // 🚀 CRITICAL FOR WEB REDIRECTION

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  RealtimeChannel? _depositSubscription; // 🚀 Keep track of stream to avoid memory leaks

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
    return normalized == 'completed' ||
        normalized == 'successful' ||
        normalized == 'success' ||
        normalized == '00';
  }

  Future<void> _awaitWebhookConfirmation(
    SupabaseClient client,
    String uniqueTxRef,
    double amount,
  ) async {
    // 1. Ensure the transaction row is initialized to pending status
    await client
        .from('deposits')
        .update({'status': 'pending'})
        .eq('tx_ref', uniqueTxRef);

    if (!mounted) return;

    // 🚀 REALTIME ENGINE: Listen for backend changes broadcasted by Supabase
    _cleanupSubscription(); // Reset any residual stream leaks safely
    
    _depositSubscription = client
        .channel('public:deposits:tx_ref=$uniqueTxRef')
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
            final String currentStatus = payload.newRecord['status'] ?? 'pending';
            
            if (currentStatus == 'completed') {
              _cleanupSubscription();
              
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _amountController.clear();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully funded NGN ${amount.toStringAsFixed(2)} via Flutterwave secure channel.',
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.go('/dashboard');
            } else if (currentStatus == 'failed') {
              _cleanupSubscription();
              if (!mounted) return;
              setState(() => _isLoading = false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment validation failed or checkout was rejected.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );

    _depositSubscription!.subscribe();

    // Give a friendly hint on web layout keeping them engaged while the other tab finishes processing
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Awaiting secure payment validation... Complete checkout in the new tab.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

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

  Future<void> _initiateDepositPipeline() async {
    if (!_formKey.currentState!.validate()) return;

    const String publicKey = Environment.flutterwavePublicKey;
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

      // 1. Log transaction payload safely into Supabase local table
      final Map<String, dynamic> depositPayload = {
        'user_id': user.id,
        'amount': inputAmount,
        'currency': 'NGN',
        'tx_ref': uniqueTxRef,
        'status': 'pending',
      };
      await client.from('deposits').insert(depositPayload);

      // 2. Platform Conditional Gateway Routing
      if (kIsWeb) {
        // 🌐 FLUTTER WEB MODE: Secure Server-Side Checkout Initialization
        
        // 🚀 NEW: Dynamically grab the exact runtime origin port address (e.g., http://localhost:61432)
        final String currentOrigin = Uri.base.origin;

        final response = await client.functions.invoke(
          'flw-webhook',
          body: {
            'action': 'initialize_payment',
            'tx_ref': uniqueTxRef,
            'amount': inputAmount.toStringAsFixed(2),
            'currency': 'NGN',
            'email': userEmail,
            'name': userName,
            // 🚀 PASS THE DYNAMIC REDIRECT URL TO THE BACKEND PAYLOAD:
            'redirect_url': '$currentOrigin/dashboard',
          },
        );

        if (response.status != 200) {
          throw Exception("Backend failed to build secure transaction session.");
        }

        final responseData = response.data is String 
            ? jsonDecode(response.data) 
            : response.data;
            
        final String? checkoutUrl = responseData['checkout_url'] ?? responseData['data']?['link'];

        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          throw Exception("Flutterwave gateway rejected standard link creation.");
        }

        final Uri checkoutUri = Uri.parse(checkoutUrl);

        if (await canLaunchUrl(checkoutUri)) {
          // Keep loader tracking live across background execution loops
          await _awaitWebhookConfirmation(client, uniqueTxRef, inputAmount);

          await launchUrl(
            checkoutUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception("System failed to follow external redirection window.");
        }

      } else {
        // 📱 MOBILE MODE: Standard Native Flutterwave UI Sheets
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
            description: "Fund your account pool via Flutterwave Checkout Gateway",
          ),
          isTestMode: true,
          redirectUrl: 'https://gisrbsjzzdtmvjsdnyym.supabase.co/functions/v1/flw-webhook',
        );

        if (!mounted) return;
        final ChargeResponse response = await flutterwave.charge(context);

        if (!mounted) return;

        final String? paymentStatus = response.status?.toLowerCase();
        final bool hasTransactionId =
            response.transactionId != null && response.transactionId!.isNotEmpty;

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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction setup failed: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
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