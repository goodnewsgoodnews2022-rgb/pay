/// Fallback stub interface for platform compilation.
/// This prevents compilation failures on Android and iOS devices.
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
  throw UnsupportedError('Web Payment Checkout is only supported on Web browsers.');
}