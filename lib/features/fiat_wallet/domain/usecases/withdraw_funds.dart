import '../repositories/fiat_repository.dart';

class WithdrawFunds {
  final FiatRepository repository;
  WithdrawFunds(this.repository);

  Future<void> call(String walletId, double amount, String reference) {
    return repository.withdraw(walletId, amount, reference);
  }
}
