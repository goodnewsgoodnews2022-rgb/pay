import 'package:fintech/features/fiat_wallet/domain/usecases/deposit_funds.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/get_fiat_balances.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/get_transaction_history.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/withdraw_funds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fiat_wallet_event.dart';
import 'fiat_wallet_state.dart';

class FiatWalletBloc extends Bloc<FiatWalletEvent, FiatWalletState> {
  final GetFiatBalances getFiatBalances;
  final DepositFunds depositFunds;
  final WithdrawFunds withdrawFunds;
  final GetTransactionHistory getTransactionHistory;

  FiatWalletBloc({
    required this.getFiatBalances,
    required this.depositFunds,
    required this.withdrawFunds,
    required this.getTransactionHistory,
  }) : super(FiatWalletInitial()) {
    on<LoadFiatBalances>(_onLoadBalances);
    on<DepositRequested>(_onDeposit);
    on<WithdrawRequested>(_onWithdraw);
    on<LoadTransactionHistory>(_onLoadHistory);
  }

  Future<void> _onLoadBalances(
    LoadFiatBalances event,
    Emitter<FiatWalletState> emit,
  ) async {
    emit(FiatWalletLoading());
    try {
      final balances = await getFiatBalances(event.userId);
      emit(FiatWalletBalancesLoaded(balances));
    } catch (e) {
      emit(FiatWalletError(e.toString()));
    }
  }

  Future<void> _onDeposit(
    DepositRequested event,
    Emitter<FiatWalletState> emit,
  ) async {
    emit(FiatWalletLoading());
    try {
      await depositFunds(event.walletId, event.amount, event.reference);
      emit(FiatWalletOperationSuccess('Deposit successful'));
      final userId = _getUserId();
      if (userId != null) add(LoadFiatBalances(userId));
    } catch (e) {
      emit(FiatWalletError(e.toString()));
    }
  }

  Future<void> _onWithdraw(
    WithdrawRequested event,
    Emitter<FiatWalletState> emit,
  ) async {
    emit(FiatWalletLoading());
    try {
      await withdrawFunds(event.walletId, event.amount, event.reference);
      emit(FiatWalletOperationSuccess('Withdrawal successful'));
      final userId = _getUserId();
      if (userId != null) add(LoadFiatBalances(userId));
    } catch (e) {
      emit(FiatWalletError(e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadTransactionHistory event,
    Emitter<FiatWalletState> emit,
  ) async {
    emit(FiatWalletLoading());
    try {
      final transactions = await getTransactionHistory(event.walletId);
      emit(FiatWalletTransactionHistoryLoaded(transactions));
    } catch (e) {
      emit(FiatWalletError(e.toString()));
    }
  }

  String? _getUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }
}
