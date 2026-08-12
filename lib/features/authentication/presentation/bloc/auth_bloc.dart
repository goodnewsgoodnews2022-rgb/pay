// ignore_for_file: avoid_print
import 'package:fintech/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/features/authentication/domain/usecases/get_current_user.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_in.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_out.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_up.dart';
import 'package:fintech/features/authentication/domain/usecases/send_password_reset.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
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
    emit(AuthLoading());
    try {
      // 1. Perform auth and profile creation through the UseCase, explicitly passing username
      final user = await signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username,
        mobileNumber: event.mobileNumber,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        address: event.address,
      );
      
      // 2. Safely auto-initialize the wallet row with explicit onConflict: 'user_id' to bypass 23505 constraints
      try {
        await supabase.Supabase.instance.client.from('wallets').upsert({
          'user_id': user.id,
          'crypto_balance': 0.0,
          'account_or_public_key': 'payme_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
        }, onConflict: 'user_id');
      } catch (walletErr) {
        print('⚠️ [AuthBloc] Wallet initialization warning: $walletErr');
      }

      // 3. Emit authenticated state so the app navigates cleanly to the profile/dashboard without mismatches
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