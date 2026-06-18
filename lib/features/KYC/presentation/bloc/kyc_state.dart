import 'package:fintech/features/KYC/domain/entities/kyc_status.dart';


abstract class KycState {}

class KycInitial extends KycState {}

class KycLoading extends KycState {}

// Biometric states
class BiometricAvailable extends KycState {
  final bool isSupported;
  BiometricAvailable(this.isSupported);
}

class BiometricSuccess extends KycState {}

class BiometricFailure extends KycState {
  final String error;
  BiometricFailure(this.error);
}

// PIN states
class PinSetSuccess extends KycState {}

class PinVerificationSuccess extends KycState {}

class PinVerificationFailure extends KycState {
  final String error;
  PinVerificationFailure(this.error);
}

// KYC status loaded
class KycStatusLoaded extends KycState {
  final KycStatus status;
  KycStatusLoaded(this.status);
}

// KYC submission result
class KycSubmissionSuccess extends KycState {}

class KycSubmissionFailure extends KycState {
  final String error;
  KycSubmissionFailure(this.error);
}

// Biometric preference states
class KycError extends KycState {
  final String message;
  KycError(this.message);
}

class KycBiometricPreferenceSaved
    extends KycState {}  // ✅ This line is correct