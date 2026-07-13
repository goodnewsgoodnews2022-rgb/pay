import '../repositories/admin_repository.dart';

class RejectKyc {
  final AdminRepository repository;
  RejectKyc(this.repository);

  Future<void> call(String userId, {String? reason}) =>
      repository.rejectKyc(userId, reason: reason);
}
