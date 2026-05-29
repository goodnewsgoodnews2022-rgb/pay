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
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      final user = response.user;
      if (user == null) throw Exception('Sign up failed');

      // Create profile entry
      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'kyc_status': 'pending',
      });

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: fullName,
        kycStatus: 'pending',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
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
      if (user == null) throw Exception('Sign in failed');

      // Fetch profile
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: profile['full_name'],
        kycStatus: profile['kyc_status'],
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
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
      fullName: profile?['full_name'],
      kycStatus: profile?['kyc_status'],
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
