import '../entities/kyc_status.dart';
import '../repositories/kyc_repository.dart';

class UpdateKycStatus {
  final KycRepository repository;

  UpdateKycStatus(this.repository);

  Future<void> call(
    String userId,
    KycStatusEnum status, {
    String? reason,
  }) {
    return repository.updateKycStatus(userId, status, reason:reason);
  }
}
