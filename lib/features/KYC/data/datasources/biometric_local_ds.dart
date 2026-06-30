import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

class BiometricLocalDataSource {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isSupported() async {
    if (kIsWeb) return false; // Guard: prevents platform crashes on web browsers
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) return false; // Guard: prevents platform crashes on web browsers
    try {
      return await _localAuth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }
}