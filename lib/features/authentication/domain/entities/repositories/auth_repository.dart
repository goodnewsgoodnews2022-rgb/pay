import 'package:fintech/features/authentication/domain/entities/app_user.dart';


abstract class AuthRepository {
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? mobileNumber,
    String? gender,
    String? dateOfBirth,
    String? address,
  });
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
}
