import 'package:fintech/features/KYC/domain/entities/kyc_status.dart';
import 'package:fintech/features/KYC/domain/usecases/authenticate_with_biometric.dart';
import 'package:fintech/features/KYC/domain/usecases/check_biometric_support.dart';
import 'package:fintech/features/KYC/domain/usecases/get_kyc_status.dart';
import 'package:fintech/features/KYC/domain/usecases/set_pin.dart';
import 'package:fintech/features/KYC/domain/usecases/update_kyc_status.dart';
import 'package:fintech/features/KYC/domain/usecases/verify_pin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  final CheckBiometricSupport checkBiometricSupport;
  final AuthenticateWithBiometric authenticateWithBiometric;
  final SetPin setPin;
  final VerifyPin verifyPin;
  final GetKycStatus getKycStatus;
  final UpdateKycStatus updateKycStatus;

  KycBloc({
    required this.checkBiometricSupport,
    required this.authenticateWithBiometric,
    required this.setPin,
    required this.verifyPin,
    required this.getKycStatus,
    required this.updateKycStatus,
  }) : super(KycInitial()) {
    on<CheckBiometricAvailability>(_onCheckBiometric);
    on<PerformBiometricAuth>(_onBiometricAuth);
    on<SavePin>(_onSavePin);
    on<VerifyPinForKyc>(_onVerifyPin);
    on<SubmitKycVerification>(_onSubmitKyc);
    on<LoadKycStatus>(_onLoadKycStatus);
    on<EnableBiometric>(_onEnableBiometric);
    on<SkipBiometric>(_onSkipBiometric);
    on<LoadBiometricStatus>(_onLoadBiometricStatus);
    on<DisableBiometric>(_onDisableBiometric);
  }

  Future<void> _onCheckBiometric(
    CheckBiometricAvailability event,
    Emitter<KycState> emit,
  ) async {
    final isSupported = await checkBiometricSupport();
    emit(BiometricAvailable(isSupported));
  }

  Future<void> _onBiometricAuth(
    PerformBiometricAuth event,
    Emitter<KycState> emit,
  ) async {
    emit(KycLoading());
    final success = await authenticateWithBiometric(
      reason: 'Complete KYC verification',
    );
    if (success) {
      emit(BiometricSuccess());
    } else {
      emit(BiometricFailure('Biometric verification failed'));
    }
  }

  Future<void> _onSavePin(SavePin event, Emitter<KycState> emit) async {
    emit(KycLoading());
    try {
      await setPin(event.pin);
      emit(PinSetSuccess());
    } catch (e) {
      emit(PinVerificationFailure('Failed to save PIN: $e'));
    }
  }

  Future<void> _onVerifyPin(
    VerifyPinForKyc event,
    Emitter<KycState> emit,
  ) async {
    emit(KycLoading());
    final isValid = await verifyPin(event.pin);
    if (isValid) {
      emit(PinVerificationSuccess());
    } else {
      emit(PinVerificationFailure('Incorrect PIN'));
    }
  }

  Future<void> _onSubmitKyc(
    SubmitKycVerification event,
    Emitter<KycState> emit,
  ) async {
    emit(KycLoading());
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      emit(KycSubmissionFailure('User not logged in'));
      return;
    }
    try {
      await updateKycStatus(userId, KycStatusEnum.APPROVED);
      emit(KycSubmissionSuccess());
    } catch (e) {
      emit(KycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onLoadKycStatus(
    LoadKycStatus event,
    Emitter<KycState> emit,
  ) async {
    emit(KycLoading());
    try {
      final status = await getKycStatus(event.userId);
      emit(KycStatusLoaded(status));
    } catch (e) {
      emit(KycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onEnableBiometric(EnableBiometric event, Emitter<KycState> emit) async {
  print('🔵 EnableBiometric called'); // <-- add this
  emit(KycLoading());
  // ... rest
  try {
    await Supabase.instance.client
        .from('profiles')
        .update({'biometric_enabled': true})
        .eq('id', Supabase.instance.client.auth.currentUser!.id);
    print('🔵 Biometric enabled saved'); // <-- add this
    emit(KycBiometricPreferenceSaved());
  } catch (e) {
    print('🔴 Error: $e');
    emit(KycError(e.toString()));
  }
}

  Future<void> _onSkipBiometric(
    SkipBiometric event,
    Emitter<KycState> emit,
  ) async {
    emit(KycLoading());
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      emit(KycError('User not logged in'));
      return;
    }
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'biometric_enabled': false})
          .eq('id', userId);
      emit(KycBiometricPreferenceSaved());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }
}

Future<void> _onLoadBiometricStatus(
  LoadBiometricStatus event,
  Emitter<KycState> emit,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    emit(KycError('User not logged in'));
    return;
  }
  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('biometric_enabled')
        .eq('id', userId)
        .single();
    final enabled = response['biometric_enabled'] ?? false;
    emit(BiometricStatusLoaded(enabled));
  } catch (e) {
    emit(KycError(e.toString()));
  }
}

Future<void> _onDisableBiometric(
  DisableBiometric event,
  Emitter<KycState> emit,
) async {
  emit(KycLoading());
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    emit(KycError('User not logged in'));
    return;
  }
  try {
    await Supabase.instance.client
        .from('profiles')
        .update({'biometric_enabled': false})
        .eq('id', userId);
    emit(KycBiometricPreferenceSaved());
  } catch (e) {
    emit(KycError(e.toString()));
  }
}
