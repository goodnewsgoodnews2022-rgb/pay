// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, undefined_function

import 'dart:html' as html;
import 'dart:js' as js;

/// Web-specific implementation of the Flutterwave Inline Checkout.
/// Dynamically injects the v3 JS library and initializes the secure payment modal.
void triggerWebCheckout({
  required String publicKey,
  required String txRef,
  required double amount,
  required String userEmail,
  required String userName,
  required String phoneNumber,
  required Function(Map<String, dynamic> response) onSuccess,
  required Function() onCancel,
  required Function(String error) onError,
}) {
  try {
    // 1. Ensure Flutterwave standard payment gateway SDK script is appended to the browser DOM
    final html.ScriptElement scriptElement = html.ScriptElement()
      ..src = 'https://checkout.flutterwave.com/v3.js'
      ..async = true;

    final existingScript = html.querySelector('script[src="https://checkout.flutterwave.com/v3.js"]');
    
    if (existingScript == null) {
      html.document.body?.append(scriptElement);
      scriptElement.onLoad.listen((_) {
        _launchFlutterwaveOverlay(
          publicKey: publicKey,
          txRef: txRef,
          amount: amount,
          userEmail: userEmail,
          userName: userName,
          phoneNumber: phoneNumber,
          onSuccess: onSuccess,
          onCancel: onCancel,
        );
      });
    } else {
      _launchFlutterwaveOverlay(
        publicKey: publicKey,
        txRef: txRef,
        amount: amount,
        userEmail: userEmail,
        userName: userName,
        phoneNumber: phoneNumber,
        onSuccess: onSuccess,
        onCancel: onCancel,
      );
    }
  } catch (e) {
    onError(e.toString());
  }
}

/// Invokes the native browser JavaScript `FlutterwaveCheckout` overlay safely.
void _launchFlutterwaveOverlay({
  required String publicKey,
  required String txRef,
  required double amount,
  required String userEmail,
  required String userName,
  required String phoneNumber,
  required Function(Map<String, dynamic> response) onSuccess,
  required Function() onCancel,
}) {
  js.context.callMethod('FlutterwaveCheckout', [
    js.JsObject.jsify({
      'public_key': publicKey,
      'tx_ref': txRef,
      'amount': amount,
      'currency': 'NGN',
      'payment_options': 'card, account, transfer, ussd',
      'customer': {
        'email': userEmail,
        'name': userName,
        'phone_number': phoneNumber,
      },
      'customizations': {
        'title': 'Wallet Cash-In',
        'description': 'Fund your account pool via Flutterwave Checkout Gateway',
      },
      'callback': js.allowInterop((response) {
        // Safe mapping from browser Javascript Object to Dart Map (Corrected typo from JsObjaect -> JsObject)
        final jsObject = js.JsObject.fromBrowserObject(response);
        final String status = (jsObject['status'] ?? jsObject['charge_response_code'] ?? 'failed').toString();
        final String transactionId = (jsObject['transaction_id'] ?? jsObject['id'] ?? '').toString();
        
        onSuccess({
          'status': status,
          'transaction_id': transactionId,
          'tx_ref': txRef,
        });
      }),
      'onclose': js.allowInterop(() {
        onCancel();
      }),
    })
  ]);
}