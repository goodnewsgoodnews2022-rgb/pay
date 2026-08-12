// ignore_for_file: avoid_print
import 'package:fintech/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/features/authentication/domain/usecases/get_current_user.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_in.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_out.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_up.dart';
import 'package:fintech/features/authentication/domain/usecases/send_password_reset.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
// ✅ Import Supabase for profile check
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUp signUp;
  final SignIn signIn;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final SendPasswordReset sendPasswordReset;
  final SignInWithGoogle signInWithGoogle;

  AuthBloc({
    required this.signUp,
    required this.signIn,
    required this.signOut,
    required this.getCurrentUser,
    required this.sendPasswordReset,
    required this.signInWithGoogle,
  }) : super(AuthInitial()) {
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
  }

  // Helper method to check if the user has a username in the database
  Future<bool> _hasUsername(String userId) async {
    try {
      final profile = await supabase.Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .maybeSingle();
      
      final username = profile?['username'];
      return username != null && username.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 [AuthBloc] SignUpRequested event received');
    emit(AuthLoading());
    try {
      final user = await signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username, // Make sure your repository handles saving this!
        mobileNumber: event.mobileNumber,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        address: event.address,
      );
      
      // Since they just signed up with a username, they are fully authenticated
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
      
      // Check if this existing user has a username set up
      final hasUser = await _hasUsername(user.id);
      if (!hasUser) {
        emit(AuthNeedsUsername(user.id));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 [AuthBloc] SignOutRequested event received');
    emit(AuthLoading());
    try {
      await signOut();
      print('✅ [AuthBloc] Sign-out successful, emitting AuthUnauthenticated');
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
      // Check if already logged-in user has a username
      final hasUser = await _hasUsername(user.id);
      if (!hasUser) {
        emit(AuthNeedsUsername(user.id));
      } else {
        emit(AuthAuthenticated(user));
      }
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

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogle();
      
      // Check username for Google sign-in accounts as well
      final hasUser = await _hasUsername(user.id);
      if (!hasUser) {
        emit(AuthNeedsUsername(user.id));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}