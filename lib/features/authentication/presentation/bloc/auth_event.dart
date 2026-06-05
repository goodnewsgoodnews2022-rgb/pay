abstract class AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? mobileNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? address;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.mobileNumber,
    this.gender,
    this.dateOfBirth,
    this.address,
  });
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  AuthPasswordResetRequested(this.email);
}
