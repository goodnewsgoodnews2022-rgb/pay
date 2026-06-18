import '../repositories/kyc_repository.dart';

class CheckBiometricSupport {
  final KycRepository repository;
  CheckBiometricSupport(this.repository);

  Future<bool> call() => repository.isBiometricSupported();
}
