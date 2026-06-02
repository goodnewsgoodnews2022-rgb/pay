import 'package:fintech/features/authentication/domain/entities/repositories/auth_repository.dart';
import '../entities/app_user.dart';


class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<AppUser?> call() {
    return repository.getCurrentUser();
  }
}
