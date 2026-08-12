import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';
import '../entities/app_user.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required String fullName,
    required String username, // ✅ Accepted username
    String? mobileNumber,
    String? gender,
    String? dateOfBirth,
    String? address,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      username: username, // ✅ Correctly forward the user-entered username to the repository
      mobileNumber: mobileNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
    );
  }
}