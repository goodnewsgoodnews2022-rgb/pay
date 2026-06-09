abstract class FiatWalletEvent {}

class LoadFiatBalances extends FiatWalletEvent {
  final String userId;
  LoadFiatBalances(this.userId);
}

class DepositRequested extends FiatWalletEvent {
  final String walletId;
  final double amount;
  final String reference;
  DepositRequested(this.walletId, this.amount, this.reference);
}

class WithdrawRequested extends FiatWalletEvent {
  final String walletId;
  final double amount;
  final String reference;
  WithdrawRequested(this.walletId, this.amount, this.reference);
}

class LoadTransactionHistory extends FiatWalletEvent {
  final String walletId;
  LoadTransactionHistory(this.walletId);
}
