import '../repositories/fiat_repository.dart';

class DepositFunds {
  final FiatRepository repository;
  DepositFunds(this.repository);

  Future<void> call(String walletId, double amount, String reference) {
    return repository.deposit(walletId, amount, reference);
  }
}
