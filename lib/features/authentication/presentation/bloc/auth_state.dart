import '../../domain/entities/app_user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

// ✅ Added state to intercept users missing a unique username
class AuthNeedsUsername extends AuthState {
  final String userId;
  AuthNeedsUsername(this.userId);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthPasswordResetSent extends AuthState {}