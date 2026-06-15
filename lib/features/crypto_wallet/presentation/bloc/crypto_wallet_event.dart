import 'package:equatable/equatable.dart';

abstract class CryptoWalletEvent extends Equatable {
  const CryptoWalletEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user requests a deposit address
class GenerateDepositAddress extends CryptoWalletEvent {
  final double amount;
  final String networkCurrency; // 'usdtbsc' (BEP20) or 'usdttrx' (TRC20)

  const GenerateDepositAddress({
    required this.amount,
    required this.networkCurrency,
  });

  @override
  List<Object?> get props => [amount, networkCurrency];
}

/// Reset state back to initial when user closes modal/overlay
class ResetCryptoWalletState extends CryptoWalletEvent {}