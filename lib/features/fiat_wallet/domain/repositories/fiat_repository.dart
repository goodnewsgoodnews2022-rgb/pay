import '../entities/fiat_account.dart';
import '../entities/fiat_transaction.dart';

abstract class FiatRepository {
  Future<List<FiatAccount>> getFiatBalances(String userId);
  Future<void> deposit(String walletId, double amount, String reference);
  Future<void> withdraw(String walletId, double amount, String reference);
  Future<List<FiatTransaction>> getTransactionHistory(
    String walletId, {
    int limit = 50,
  });
}
