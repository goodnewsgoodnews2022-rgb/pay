import 'package:fintech/features/authentication/domain/entities/app_user.dart'; 

abstract class AuthRepository {
  Future<AppUser> signUp(String email, String password, String fullName);
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
}
