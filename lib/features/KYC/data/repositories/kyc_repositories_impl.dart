import 'dart:convert';

import 'package:fintech/features/KYC/domain/entities/kyc_status.dart';
import 'package:fintech/features/KYC/domain/repositories/kyc_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/biometric_local_ds.dart';
import '../datasources/pin_local_ds.dart';
import '../models/kyc_status_model.dart';

class KycRepositoryImpl implements KycRepository {
  final BiometricLocalDataSource _biometricDS;
  final PinLocalDataSource _pinDS;
  final SupabaseClient _supabase;

  KycRepositoryImpl({
    required BiometricLocalDataSource biometricDS,
    required PinLocalDataSource pinDS,
    SupabaseClient? supabase,
  }) : _biometricDS = biometricDS,
       _pinDS = pinDS,
       _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<bool> isBiometricSupported() => _biometricDS.isSupported();

  @override
  Future<bool> authenticateWithBiometric({String? reason}) =>
      _biometricDS.authenticate(reason: reason ?? 'Verify your Identity');

  @override
  Future<void> setPin(String pin) => _pinDS.savePin(pin);

  @override
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _pinDS.getHashedPin();
    if (storedHash == null) return false;
    final inputHash = base64.encode(utf8.encode(pin));
    return storedHash == inputHash;
  }

  @override
  Future<KycStatus> getKycStatus(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('kyc_status, kyc_rejection_reason')
        .eq('id', userId)
        .single();
    return KycStatusModel.fromJson(response);
  }

  @override
  Future<void> updateKycStatus(
    String userId,
    KycStatusEnum status, {
    String? reason,
  }) async {
    final updates = <String, dynamic>{
      'kyc_status': status.name,
      if (reason != null) 'kyc_rejection_reason': reason,
    };
    await _supabase.from('profiles').update(updates).eq('id', userId);
  }
}
