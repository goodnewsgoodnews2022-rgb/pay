import '../repositories/admin_repository.dart';

class ApproveKyc {
  final AdminRepository repository;
  ApproveKyc(this.repository);

  Future<void> call(String userId) => repository.approveKyc(userId);
}
