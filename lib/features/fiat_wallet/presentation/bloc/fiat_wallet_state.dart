import 'package:fintech/features/fiat_wallet/domain/entities/fiat_account.dart';
import 'package:fintech/features/fiat_wallet/domain/entities/fiat_transaction.dart';

abstract class FiatWalletState {}

class FiatWalletInitial extends FiatWalletState {}

class FiatWalletLoading extends FiatWalletState {}

class FiatWalletBalancesLoaded extends FiatWalletState {
  final List<FiatAccount> balances;
  FiatWalletBalancesLoaded(this.balances);
}

class FiatWalletTransactionHistoryLoaded extends FiatWalletState {
  final List<FiatTransaction> transactions;
  FiatWalletTransactionHistoryLoaded(this.transactions);
}

class FiatWalletOperationSuccess extends FiatWalletState {
  final String message;
  FiatWalletOperationSuccess(this.message);
}

class FiatWalletError extends FiatWalletState {
  final String message;
  FiatWalletError(this.message);
}
