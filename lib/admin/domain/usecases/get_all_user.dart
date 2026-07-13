import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class GetAllUsers {
  final AdminRepository repository;
  GetAllUsers(this.repository);

  Future<List<AdminUser>> call({int limit = 50, int offset = 0}) =>
      repository.getAllUsers(limit: limit, offset: offset);
}
