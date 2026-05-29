import 'package:fintech/features/authentication/domain/entities/app_user.dart';
import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<AppUser> call(String email, String password, String fullName) {
    return repository.signUp(email, password, fullName);
  }
}
