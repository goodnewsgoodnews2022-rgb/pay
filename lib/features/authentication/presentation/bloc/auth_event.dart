abstract class AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String username; // ✅ Added username field
  final String? mobileNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? address;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.username, // ✅ Required in constructor
    this.mobileNumber,
    this.gender,
    this.dateOfBirth,
    this.address,
  });
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested({required this.email, required this.password});
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  AuthPasswordResetRequested({required this.email});
}

class AuthSignInWithGoogleRequested extends AuthEvent {}