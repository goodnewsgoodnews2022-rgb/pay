import '../entities/kyc_status.dart';

abstract class KycRepository {
  Future<bool> isBiometricSupported();
  Future<bool> authenticateWithBiometric({String? reason});
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<KycStatus> getKycStatus(String userId);
  Future<void> updateKycStatus(
    String userId,
    KycStatusEnum status, {
    String? reason,
  });
}
