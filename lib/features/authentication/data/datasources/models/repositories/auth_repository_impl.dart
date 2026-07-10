// ignore_for_file: avoid_print

import 'dart:async';

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
    String? mobileNumber,
    String? gender,
    String? dateOfBirth,
    String? address,
  }) async {
    try {
      // 1. Create the Auth User with Metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
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

      // 2. Explicitly create the public profile document entry safely
      try {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'mobile_number': mobileNumber,
          'gender': gender,
          'date_of_birth': dateOfBirth,
          'address': address,
          'kyc_status': 'PENDING',
        });
      } catch (dbError) {
        throw AuthException(
          'Auth account created, but profile generation failed. RLS policies or schema columns might be mismatched: $dbError',
        );
      }

      // 3. Fetch the created profile to get generated account_number
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: fullName,
        mobileNumber: mobileNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        address: address,
        accountNumber: profile['account_number'],
        kycStatus: 'PENDING',
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
      // 1. Authenticate with credentials
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Login failed: user payload missing.');
      }

      // 2. Fetch the corresponding profile document defensively
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // Fallback gracefully if the profile record is entirely missing or null
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
      );
    } catch (e) {
      // Return null to drop session gracefully instead of crashing global BLoC lifecycle
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

  // ✅ Google Sign‑In (inside the class)
  Future<AppUser> signInWithGoogle() async {
    try {
      final completer = Completer<AppUser>();
      StreamSubscription<AuthState>? subscription;

      subscription = _supabase.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn) {
          final session = data.session;
          if (session != null) {
            final user = session.user;
            final appUser = await _getOrCreateUserFromSession(user);
            if (!completer.isCompleted) {
              completer.complete(appUser);
              subscription?.cancel();
            }
                    }
        }
      });

      const redirectUrl = kIsWeb
          ? null // web uses default Supabase redirect (page reload)
          : 'com.yourcompany.fintech://login-callback'; // mobile custom scheme

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

    if (profile == null) {
      // Create minimal profile
      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': user.userMetadata?['full_name'] ?? 'Fintech User',
        'kyc_status': 'PENDING',
      });

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
      );
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
    );
  }
}
