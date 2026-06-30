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
          onError: onError,
        );
      });
    } else {
      // Script exists. Ensure it has fully loaded and the global function is defined before calling
      _waitForSDKAndLaunch(
        publicKey: publicKey,
        txRef: txRef,
        amount: amount,
        userEmail: userEmail,
        userName: userName,
        phoneNumber: phoneNumber,
        onSuccess: onSuccess,
        onCancel: onCancel,
        onError: onError,
      );
    }
  } catch (e) {
    onError(e.toString());
  }
}

/// Repeatedly checks if the script is loaded and compiled in the JS Context to prevent race condition crashes
void _waitForSDKAndLaunch({
  required String publicKey,
  required String txRef,
  required double amount,
  required String userEmail,
  required String userName,
  required String phoneNumber,
  required Function(Map<String, dynamic> response) onSuccess,
  required Function() onCancel,
  required Function(String error) onError,
  int attempts = 0,
}) {
  if (js.context.hasProperty('FlutterwaveCheckout')) {
    _launchFlutterwaveOverlay(
      publicKey: publicKey,
      txRef: txRef,
      amount: amount,
      userEmail: userEmail,
      userName: userName,
      phoneNumber: phoneNumber,
      onSuccess: onSuccess,
      onCancel: onCancel,
      onError: onError,
    );
  } else if (attempts < 30) {
    // Try again in 100ms
    Future.delayed(const Duration(milliseconds: 100), () {
      _waitForSDKAndLaunch(
        publicKey: publicKey,
        txRef: txRef,
        amount: amount,
        userEmail: userEmail,
        userName: userName,
        phoneNumber: phoneNumber,
        onSuccess: onSuccess,
        onCancel: onCancel,
        onError: onError,
        attempts: attempts + 1,
      );
    });
  } else {
    onError("Flutterwave SDK loaded in browser but failed to initialize standard bindings.");
  }
}

/// Safely scans the browser DOM and removes any active payment iframe elements as a fallback
void _destroyPaymentOverlays() {
  try {
    html.document.querySelectorAll('iframe').forEach((element) {
      final iframe = element as html.IFrameElement;
      final String? src = iframe.src;
      
      // Defensively check for null to prevent compile-time analyzer exceptions on sound null safety environments
      if (src != null && (src.contains('flutterwave') || src.contains('rave'))) {
        iframe.remove();
      }
    });
    html.document.getElementById('flw-iframe-container')?.remove();
    html.document.querySelectorAll('.flw-payment-modal').forEach((el) => el.remove());
  } catch (_) {}
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
  required Function(String error) onError,
}) {
  try {
    if (!js.context.hasProperty('FlutterwaveCheckout')) {
      throw Exception("Flutterwave JS SDK not ready in the browser context.");
    }

    // Capture reference to JavaScript payment instance to close it dynamically later
    dynamic checkoutHandler;

    checkoutHandler = js.context.callMethod('FlutterwaveCheckout', [
      js.JsObject.jsify({
        'public_key': publicKey,
        'tx_ref': txRef,
        'amount': amount,
        'currency': 'NGN',
        'payment_options': 'card, ussd, banktransfer',
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
          try {
            // Safe local copy of dynamic reference
            final activeHandler = checkoutHandler;
            if (activeHandler != null) {
              try {
                // Instruct JS SDK to run its default close processes 
                activeHandler.callMethod('close');
              } catch (_) {
                // If the SDK has already self-destructed, fallback immediately
                _destroyPaymentOverlays();
              }
            }
            
            // Postpone cleanup sweep to allow Flutterwave v3.js to complete close actions smoothly
            Future.delayed(const Duration(milliseconds: 600), () {
              _destroyPaymentOverlays();
            });

            final jsObject = js.JsObject.fromBrowserObject(response);
            final String status = (jsObject['status'] ?? jsObject['charge_response_code'] ?? 'failed').toString();
            final String transactionId = (jsObject['transaction_id'] ?? jsObject['id'] ?? '').toString();
            
            onSuccess({
              'status': status,
              'transaction_id': transactionId,
              'tx_ref': txRef,
            });
          } catch (e) {
            _destroyPaymentOverlays();
            onError("Error processing payment callback: $e");
          }
        }),
        'onclose': js.allowInterop(() {
          Future.delayed(const Duration(milliseconds: 600), () {
            _destroyPaymentOverlays();
          });
          onCancel();
        }),
      })
    ]);
  } catch (e) {
    onError(e.toString());
  }
}