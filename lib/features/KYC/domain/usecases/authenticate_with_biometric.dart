import '../repositories/kyc_repository.dart';

class AuthenticateWithBiometric {
  final KycRepository repository;
  AuthenticateWithBiometric(this.repository);

  Future<bool> call({String? reason}) =>
      repository.authenticateWithBiometric(reason: reason);
}
