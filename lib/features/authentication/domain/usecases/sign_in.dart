import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';
import '../entities/app_user.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
