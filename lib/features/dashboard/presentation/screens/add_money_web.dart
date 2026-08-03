// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:js_interop';

@JS('FlutterwaveCheckout')
external void flutterwaveCheckout(JSObject options);

void handleWebPayment({
  required BuildContext context,
  required String publicKey,
  required String transactionId,
  required double amount,
  required String amountText,
  required String userIdentifier,
  required ValueChanged<bool> onProcessingChanged,
}) {
  final Map<String, dynamic> checkoutOptions = {
    'public_key': publicKey,
    'tx_ref': transactionId,
    'amount': amount,
    'currency': 'NGN',
    'payment_options': 'card,banktransfer,ussd',
    'redirect_url': '${Uri.base.origin}/dashboard',
    'customer': {
      'email': 'user@example.com',
      'phone_number': '08012345678',
      'name': 'Test User',
    },
    'customizations': {
      'title': 'Fund Wallet',
      'description': 'Fund wallet balance with NGN $amountText',
      'logo': 'https://flutterwave.com/images/logo/logo-mark.svg',
    },
    'callback': ((JSObject responseObj) {
      Future.microtask(() async {
        try {
          final Map resMap = responseObj.dartify() as Map;
          
          if (resMap['status'] == 'successful' || resMap['status'] == 'completed') {
            await Supabase.instance.client
                .from('transactions')
                .update({'status': 'success'})
                .eq('id', transactionId);

            try {
              await Supabase.instance.client.rpc(
                'update_wallet_balance',
                params: {'user_id': userIdentifier, 'amount_to_add': amount},
              );
            } catch (_) {
              final balanceRes = await Supabase.instance.client
                  .from('wallet_balances')
                  .select('naira_balance')
                  .eq('user_identifier', userIdentifier)
                  .maybeSingle();

              final double currentBalance = (balanceRes?['naira_balance'] ?? 0.0).toDouble();
              await Supabase.instance.client.from('wallet_balances').upsert({
                'user_identifier': userIdentifier,
                'naira_balance': currentBalance + amount,
                'updated_at': DateTime.now().toIso8601String(),
              });
            }

            if (context.mounted) {
              onProcessingChanged(false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("₦${amount.toStringAsFixed(2)} added successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(true);
            }
          } else {
            await Supabase.instance.client
                .from('transactions')
                .update({'status': 'canceled'})
                .eq('id', transactionId);

            if (context.mounted) {
              onProcessingChanged(false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payment was cancelled or failed."),
                  backgroundColor: Colors.amber,
                ),
              );
            }
          }
        } catch (_) {
          if (context.mounted) {
            onProcessingChanged(false);
          }
        }
      });
    }).toJS,
    'onclose': (() {
      Future.microtask(() async {
        try {
          final checkTx = await Supabase.instance.client
              .from('transactions')
              .select('status')
              .eq('id', transactionId)
              .maybeSingle();

          if (checkTx != null && checkTx['status'] == 'pending') {
            await Supabase.instance.client
                .from('transactions')
                .update({'status': 'canceled'})
                .eq('id', transactionId);
          }
        } catch (_) {}

        if (context.mounted) {
          onProcessingChanged(false);
        }
      });
    }).toJS,
  };

  flutterwaveCheckout(checkoutOptions.jsify()! as JSObject);
}