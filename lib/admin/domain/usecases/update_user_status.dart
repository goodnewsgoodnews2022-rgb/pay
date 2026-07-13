import '../repositories/admin_repository.dart';

class UpdateUserStatus {
  final AdminRepository repository;
  UpdateUserStatus(this.repository);

  Future<void> call(
    String userId, {
    bool? isSuspended,
    String? suspensionReason,
  }) => repository.updateUserStatus(
    userId,
    isSuspended: isSuspended,
    suspensionReason: suspensionReason,
  );
}
