import '../repositories/kyc_repository.dart';

class SetPin {
  final KycRepository repository;
  SetPin(this.repository);

  Future<void> call(String pin) => repository.setPin(pin);
}
