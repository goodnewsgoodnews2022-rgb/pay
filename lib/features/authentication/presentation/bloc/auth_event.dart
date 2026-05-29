abstract class AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  AuthSignUpRequested(this.email, this.password, this.fullName);
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
