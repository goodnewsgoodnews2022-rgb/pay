abstract class KycEvent {}

class CheckBiometricAvailability extends KycEvent {}

// For the main KYC flow (e.g., after signup)
class StartKycFlow extends KycEvent {}

// Biometric steps
class PerformBiometricAuth extends KycEvent {}

// PIN steps
class SavePin extends KycEvent {
  final String pin;
  SavePin(this.pin);
}

class VerifyPinForKyc extends KycEvent {
  final String pin;
  VerifyPinForKyc(this.pin);
}

// Update server status
class SubmitKycVerification
    extends KycEvent {} // after biometric+pin success

// Load current KYC status (e.g., on dashboard)
class LoadKycStatus extends KycEvent {
  final String userId;
  LoadKycStatus(this.userId);
}

class EnableBiometric extends KycEvent {}

class SkipBiometric extends KycEvent {}
