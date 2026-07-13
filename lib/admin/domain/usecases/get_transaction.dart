import '../entities/admin_transaction.dart';
import '../repositories/admin_repository.dart';

class GetTransactions {
  final AdminRepository repository;
  GetTransactions(this.repository);

  Future<List<AdminTransaction>> call({
    String? type,
    String? status,
    int limit = 50,
  }) =>
      repository.getTransactions(type: type, status: status, limit: limit);
}
