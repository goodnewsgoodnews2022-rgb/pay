import '../entities/fiat_account.dart';
import '../repositories/fiat_repository.dart';

class GetFiatBalances {
  final FiatRepository repository;
  GetFiatBalances(this.repository);

  Future<List<FiatAccount>> call(String userId) {
    return repository.getFiatBalances(userId);
  }
}
