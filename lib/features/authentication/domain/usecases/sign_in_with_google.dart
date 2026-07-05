import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';

import '../entities/app_user.dart';


class SignInWithGoogle {
  final AuthRepository repository;
  
  SignInWithGoogle(this.repository);

  Future<AppUser> call() => (repository as dynamic).signInWithGoogle();
  
}
