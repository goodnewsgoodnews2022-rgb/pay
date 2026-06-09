import '../entities/fiat_transaction.dart';
import '../repositories/fiat_repository.dart';

class GetTransactionHistory {
  final FiatRepository repository;
  GetTransactionHistory(this.repository);

  Future<List<FiatTransaction>> call(String walletId, {int limit = 50}) {
    return repository.getTransactionHistory(walletId, limit: limit);
  }
}
