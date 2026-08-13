// ignore_for_file: unnecessary_null_comparison, override_on_non_overriding_member, avoid_print

import 'dart:async';
import 'dart:html' as html show window;

import 'package:fintech/features/authentication/data/datasources/models/app_user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintech/features/authentication/domain/entities/app_user.dart';
import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    String? mobileNumber,
    String? gender,
    String? dateOfBirth,
    String? address,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
          'mobile_number': mobileNumber,
          'gender': gender,
          'date_of_birth': dateOfBirth,
          'address': address,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          'Registration returned an empty user payload.',
        );
      }

      // ✅ Insert/Upsert complete user profile into the profiles table with the username
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'username': username,
        'mobile_number': mobileNumber,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'address': address,
        'kyc_status': 'PENDING',
        'is_admin': false,
        'is_suspended': false,
      }, onConflict: 'id');

      // ✅ Completely safe null-safe wallet row check and dynamic key assignment
      final existingWallet = await _supabase
          .from('wallets')
          .select('account_or_public_key')
          .eq('user_id', user.id)
          .maybeSingle();

      String validPublicKey;
      if (existingWallet == null || existingWallet['account_or_public_key'] == null) {
        validPublicKey = 'payme_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        final currentKey = existingWallet['account_or_public_key'].toString().trim();
        validPublicKey = currentKey.isEmpty
            ? 'payme_${user.id}_${DateTime.now().millisecondsSinceEpoch}'
            : currentKey;
      }

      await _supabase.from('wallets').upsert({
        'user_id': user.id,
        'crypto_balance': 0.0,
        'account_or_public_key': validPublicKey,
      }, onConflict: 'user_id');

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: fullName,
        mobileNumber: mobileNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        address: address,
        accountNumber: profile?['account_number'],
        kycStatus: profile?['kyc_status'] ?? 'PENDING',
        isAdmin: profile?['is_admin'] ?? false,
        isSuspended: profile?['is_suspended'] ?? false,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected signup error occurred: $e');
    }
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Login failed: user payload missing.');
      }

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // ✅ BLOCK SUSPENDED USERS
      if (profile?['is_suspended'] == true) {
        // Sign out immediately to clear the session
        await _supabase.auth.signOut();
        throw const AuthException(
          'Your account has been suspended. Please contact support.',
        );
      }

      final String finalFullName =
          profile?['full_name'] ??
          (user.userMetadata?['full_name'] ?? 'Fintech User');
      final String finalKycStatus = profile?['kyc_status'] ?? 'PENDING';

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: finalFullName,
        mobileNumber: profile?['mobile_number'],
        gender: profile?['gender'],
        dateOfBirth: profile?['date_of_birth'],
        address: profile?['address'],
        avatarUrl: profile?['avatar_url'],
        accountNumber: profile?['account_number'],
        kycStatus: finalKycStatus,
        biometricEnabled: profile?['biometric_enabled'] ?? false,
        isAdmin: profile?['is_admin'] ?? false,
        isSuspended: profile?['is_suspended'] ?? false,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected signin error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out execution encountered an error: $e');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;
      final user = session.user;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) return null;

      // ✅ BLOCK SUSPENDED USERS FROM RESTORING SESSION
      if (profile['is_suspended'] == true) {
        await _supabase.auth.signOut();
        return null;
      }

      return AppUserModel.fromSupabaseUser(
        user,
        fullName:
            profile['full_name'] ??
            (user.userMetadata?['full_name'] ?? 'Fintech User'),
        mobileNumber: profile['mobile_number'],
        gender: profile['gender'],
        dateOfBirth: profile['date_of_birth'],
        address: profile['address'],
        avatarUrl: profile['avatar_url'],
        accountNumber: profile['account_number'],
        kycStatus: profile['kyc_status'] ?? 'PENDING',
        biometricEnabled: profile['biometric_enabled'] ?? false,
        isAdmin: profile['is_admin'] ?? false,
        isSuspended: profile['is_suspended'] ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final completer = Completer<AppUser>();
      StreamSubscription<AuthState>? subscription;

      subscription = _supabase.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn) {
          final session = data.session;
          if (session != null) {
            final user = session.user;
            if (user != null) {
              try {
                final appUser = await _getOrCreateUserFromSession(user);
                if (!completer.isCompleted) {
                  completer.complete(appUser);
                  subscription?.cancel();
                }
              } catch (e) {
                // Handle error (e.g., suspension)
                if (!completer.isCompleted) {
                  completer.completeError(e);
                  subscription?.cancel();
                }
              }
            }
          }
        }
      });

      // ✅ Captures the ACTUAL current origin (protocol + host + port) at
      // sign-in time, so it works no matter which port Flutter picked.
      // Requires "http://localhost:**" to be added under Supabase ->
      // Authentication -> URL Configuration -> Redirect URLs.
      final redirectUrl = kIsWeb
          ? html.window.location.origin
          : 'com.yourcompany.fintech://login-callback';

      print('🔍 [Google Sign-In] Using redirectTo: $redirectUrl');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          subscription?.cancel();
          throw Exception('Google sign-in timed out');
        },
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ✅ Helper – also inside the class
  Future<AppUser> _getOrCreateUserFromSession(User user) async {
    // Try fetch profile
    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // ✅ Check suspension
    if (profile != null && profile['is_suspended'] == true) {
      // Sign out immediately to clear session
      await _supabase.auth.signOut();
      throw AuthException('Your account has been suspended.');
    }

    if (profile == null) {
      // Create minimal profile
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': user.userMetadata?['full_name'] ?? 'Fintech User',
        'kyc_status': 'PENDING',
        'is_admin': false,
        'biometric_enabled': false,
        'is_suspended': false,
      }, onConflict: 'id');

      final created = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: created['full_name'],
        mobileNumber: created['mobile_number'],
        gender: created['gender'],
        dateOfBirth: created['date_of_birth'],
        address: created['address'],
        avatarUrl: created['avatar_url'],
        accountNumber: created['account_number'],
        kycStatus: created['kyc_status'] ?? 'PENDING',
        biometricEnabled: created['biometric_enabled'] ?? false,
        isAdmin: created['is_admin'] ?? false,
        isSuspended: created['is_suspended'] ?? false,
      );
    }

    return AppUserModel.fromSupabaseUser(
      user,
      fullName: profile['full_name'] ?? (user.userMetadata?['full_name'] ?? 'Fintech User'),
      mobileNumber: profile['mobile_number'],
      gender: profile['gender'],
      dateOfBirth: profile['date_of_birth'],
      address: profile['address'],
      avatarUrl: profile['avatar_url'],
      accountNumber: profile['account_number'],
      kycStatus: profile['kyc_status'] ?? 'PENDING',
      biometricEnabled: profile['biometric_enabled'] ?? false,
      isAdmin: profile['is_admin'] ?? false,
      isSuspended: profile['is_suspended'] ?? false,
    );
  }
}