import '../entities/kyc_status.dart';
import '../repositories/kyc_repository.dart';

class GetKycStatus {
  final KycRepository repository;
  GetKycStatus(this.repository);

  Future<KycStatus> call(String userId) => repository.getKycStatus(userId);
}
