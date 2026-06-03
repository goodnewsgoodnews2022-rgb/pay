import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/features/authentication/domain/usecases/get_current_user.dart'; 
import 'package:fintech/features/authentication/domain/usecases/sign_in.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_out.dart'; 
import 'package:fintech/features/authentication/domain/usecases/sign_up.dart';
import 'package:fintech/features/authentication/domain/usecases/send_password_reset.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUp signUp;
  final SignIn signIn;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final SendPasswordReset sendPasswordReset;

  AuthBloc({
    required this.signUp,
    required this.signIn,
    required this.signOut,
    required this.getCurrentUser,
    required this.sendPasswordReset,
  }) : super(AuthInitial()) {
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthPasswordResetRequested>(_onPasswordReset);
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        mobileNumber: event.mobileNumber,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        address: event.address,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signIn(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await sendPasswordReset(event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
