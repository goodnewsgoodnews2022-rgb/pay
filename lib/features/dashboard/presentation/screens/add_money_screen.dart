// ignore_for_file: unnecessary_nullable_for_final_variable_declarations, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintech/app/config/environment.dart';

// Conditionally route web payment logic so mobile builds never touch js libraries
import 'add_money_stub.dart'
    if (dart.library.js_interop) 'add_money_web.dart';

class AddMoneyScreen extends StatefulWidget {
  final String userIdentifier;
  const AddMoneyScreen({super.key, required this.userIdentifier});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  final List<double> _quickAmounts = [1000, 2500, 5000, 10000, 25000, 50000];

  @override
  void initState() {
    super.initState();
    // 🛡️ Ensure any lingering global snackbars are cleared when opening this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  void _handlePayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an amount greater than 0"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    String? transactionId;
    bool isPaymentSuccessful = false;

    // --- SECTION 1: DATABASE & PAYMENT API CALLS ---
    try {
      // 1. Create Pending Transaction in Supabase
      final response = await Supabase.instance.client
          .from('transactions')
          .insert({
            'user_identifier': widget.userIdentifier,
            'amount': amount,
            'type': 'deposit',
            'status': 'pending',
          })
          .select()
          .single();

      transactionId = response['id'] as String;

      // 🌐 2. WEB vs MOBILE PLATFORM SPLIT
      if (kIsWeb) {
        handleWebPayment(
          context: context,
          publicKey: Environment.flutterwavePublicKey,
          transactionId: transactionId,
          amount: amount,
          amountText: amountText,
          userIdentifier: widget.userIdentifier,
          onProcessingChanged: (processing) {
            if (mounted) setState(() => _isProcessing = processing);
          },
        );
        return;
      } else {
        // 2. Initialize Flutterwave for Mobile
        final Customer customer = Customer(
          name: "Test User",
          phoneNumber: "08012345678",
          email: "user@example.com",
        );

        final Flutterwave flutterwave = Flutterwave(
          publicKey: Environment.flutterwavePublicKey,
          currency: "NGN",
          redirectUrl: Environment.flutterwaveRedirectUrl,
          txRef: transactionId,
          amount: amount.toStringAsFixed(2),
          customer: customer,
          paymentOptions: "card, banktransfer, ussd",
          isTestMode: true,
          customization: Customization(
            title: "Fund Wallet",
            description: "Fund wallet balance with NGN $amountText",
          ),
        );

        // 3. Trigger charge
        final ChargeResponse? chargeResponse = await flutterwave.charge(context);

        // 4. Handle Response - Backend Data Only
        if (chargeResponse != null &&
            (chargeResponse.success == true ||
                chargeResponse.status == "successful")) {
          isPaymentSuccessful = true;
        } else {
          await Supabase.instance.client
              .from('transactions')
              .update({'status': 'canceled'})
              .eq('id', transactionId);
        }
      }

      // If successful (Mobile flow charge response)
      if (isPaymentSuccessful) {
        // Update Transaction Status to Success
        await Supabase.instance.client
            .from('transactions')
            .update({'status': 'success'})
            .eq('id', transactionId);

        // Update Wallet Balance
        try {
          await Supabase.instance.client.rpc(
            'update_wallet_balance',
            params: {'user_id': widget.userIdentifier, 'amount_to_add': amount},
          );
        } catch (rpcError) {
          final balanceRes = await Supabase.instance.client
              .from('wallet_balances')
              .select('naira_balance')
              .eq('user_identifier', widget.userIdentifier)
              .maybeSingle();

          final double currentBalance = (balanceRes?['naira_balance'] ?? 0.0).toDouble();
          final double newBalance = currentBalance + amount;

          await Supabase.instance.client.from('wallet_balances').upsert({
            'user_identifier': widget.userIdentifier,
            'naira_balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint("Error in mobile payment process: $e");
      if (transactionId != null && !isPaymentSuccessful && !kIsWeb) {
        try {
          await Supabase.instance.client
              .from('transactions')
              .update({'status': 'canceled'})
              .eq('id', transactionId);
        } catch (_) {}
      }
    }

    // --- SECTION 2: UI ROUTING OUTSIDE THE TRY/CATCH (Mobile Only) ---
    if (!mounted || kIsWeb) return;

    setState(() => _isProcessing = false);

    if (isPaymentSuccessful) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("₦${amount.toStringAsFixed(2)} added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/dashboard');
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment was cancelled or failed."),
          backgroundColor: Colors.amber,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: const Text(
          "Fund Wallet",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header description
              const Text(
                "Enter the amount you would like to add to your wallet.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Amount Input Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C2C35), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AMOUNT",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      enabled: !_isProcessing,
                      decoration: const InputDecoration(
                        prefixText: "₦ ",
                        prefixStyle: TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: "0.00",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 32),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick amount selector
              const Text(
                "Quick Select",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: _quickAmounts.length,
                itemBuilder: (context, index) {
                  final amount = _quickAmounts[index];
                  return InkWell(
                    onTap: _isProcessing
                        ? null
                        : () {
                            setState(() {
                              _amountController.text = amount.toStringAsFixed(0);
                            });
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2B2B35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "₦${amount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Action button
              ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade400,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.purpleAccent.shade100
                      .withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.purpleAccent.withValues(alpha: 0.3),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Pay Securely with Flutterwave",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}