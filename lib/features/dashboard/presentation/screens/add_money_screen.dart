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

  // CORRECTED: Listener only listens, does not perform redundant updates
  Future<void> _awaitWebhookConfirmation(String uniqueTxRef, double amount) async {
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit successful!'), backgroundColor: Colors.green));
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

      // 1. Insert Initial Row
      await client.from('deposits').insert({
        'user_id': user.id,
        'amount': inputAmount,
        'tx_ref': uniqueTxRef,
        'status': 'pending',
      });

      // 2. Start Listening BEFORE launching URL
      await _awaitWebhookConfirmation(uniqueTxRef, inputAmount);

      // 3. Launch Payment Gateway
      if (kIsWeb) {
        final response = await client.functions.invoke('flw-webhook', body: {
          'action': 'initialize_payment',
          'tx_ref': uniqueTxRef,
          'amount': inputAmount.toString(),
        });
        
        final checkoutUrl = response.data['checkout_url'];
        await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      } else {
        // Native mobile implementation...
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your existing build method remains valid)
    return const Scaffold(body: Center(child: Text("Add Money Screen")));
  }
}