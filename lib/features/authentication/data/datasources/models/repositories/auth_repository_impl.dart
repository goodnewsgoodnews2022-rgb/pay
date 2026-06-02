import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintech/features/authentication/domain/entities/app_user.dart';
import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';
import 'package:fintech/features/authentication/data/datasources/models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AppUser> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // 1. Create the Auth User with Metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      
      final user = response.user;
      if (user == null) throw const AuthException('Registration returned an empty user payload.');

      // 2. Explicitly create the public profile document entry
      // Using an isolated call ensuring errors here are explicitly caught
      try {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'kyc_status': 'pending',
        });
      } catch (dbError) {
        throw AuthException(
          'Auth account created, but profile generation failed. RLS policies or schema columns might be mismatched: $dbError',
        );
      }

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: fullName,
        kycStatus: 'pending',
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
      if (user == null) throw const AuthException('Login failed: user payload missing.');

      // 2. Fetch the corresponding profile document defensively
      // Swapping out .single() for .maybeSingle() prevents hard crashes (PGRST116)
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // Fallback gracefully if the profile record is entirely missing
      final String finalFullName = profile?['full_name'] ?? (user.userMetadata?['full_name'] ?? 'Fintech User');
      final String finalKycStatus = profile?['kyc_status'] ?? 'pending';

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: finalFullName,
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

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: profile?['full_name'] ?? (user.userMetadata?['full_name'] ?? 'Fintech User'),
        kycStatus: profile?['kyc_status'] ?? 'pending',
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
}