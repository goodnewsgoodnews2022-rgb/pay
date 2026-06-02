import 'package:fintech/features/authentication/data/datasources/models/app_user_model.dart';
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
      if (user == null) throw Exception('Sign up failed');

      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'mobile_number': mobileNumber,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'address': address,
        // 'kyc_status': 'pending',
      });

      // Fetch the created profile to get generated account_number
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
        // kycStatus: 'pending',
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

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return AppUserModel.fromSupabaseUser(
        user,
        fullName: profile['full_name'],
        mobileNumber: profile['mobile_number'],
        gender: profile['gender'],
        dateOfBirth: profile['date_of_birth'],
        address: profile['address'],
        avatarUrl: profile['avatar_url'],
        accountNumber: profile['account_number'],
        // kycStatus: profile['kyc_status'],
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

    if (profile == null) return null;

    return AppUserModel.fromSupabaseUser(
      user,
      fullName: profile['full_name'],
      mobileNumber: profile['mobile_number'],
      gender: profile['gender'],
      dateOfBirth: profile['date_of_birth'],
      address: profile['address'],
      avatarUrl: profile['avatar_url'],
      accountNumber: profile['account_number'],
      // kycStatus: profile['kyc_status'],
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
