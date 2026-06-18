import '../repositories/kyc_repository.dart';

class VerifyPin {
  final KycRepository repository;
  VerifyPin(this.repository);

  Future<bool> call(String pin) => repository.verifyPin(pin);
}
