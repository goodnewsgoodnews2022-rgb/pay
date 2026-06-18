import 'package:local_auth/local_auth.dart';

class BiometricLocalDataSource {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isSupported() async {
    return await _localAuth.isDeviceSupported();
  }

 Future<bool> authenticate({required String reason}) async {
  return await _localAuth.authenticate(
    localizedReason: reason,
    options: const AuthenticationOptions(
      stickyAuth: true,
      biometricOnly: true,
    ),
  );
}

}