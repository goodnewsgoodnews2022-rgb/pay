import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';
import '../entities/app_user.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required String fullName,
    String? mobileNumber,
    String? gender,
    String? dateOfBirth,
    String? address,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      mobileNumber: mobileNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
    );
  }
}
