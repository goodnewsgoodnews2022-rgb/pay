import 'package:equatable/equatable.dart';

abstract class CryptoSwapEvent extends Equatable {
  const CryptoSwapEvent();

  @override
  List<Object?> get props => [];
}

class ToggleSwapDirection extends CryptoSwapEvent {}

class CalculateSwapAmounts extends CryptoSwapEvent {
  final double inputAmount;
  const CalculateSwapAmounts({required this.inputAmount});

  @override
  List<Object?> get props => [inputAmount];
}

/// Dispatched when the user switches the selected Fiat currency option
class ChangeFiatCurrency extends CryptoSwapEvent {
  final String newFiat;
  const ChangeFiatCurrency({required this.newFiat});

  @override
  List<Object?> get props => [newFiat];
}

/// Dispatched when the user switches the selected Crypto token asset option
class ChangeCryptoCurrency extends CryptoSwapEvent {
  final String newCrypto;
  const ChangeCryptoCurrency({required this.newCrypto});

  @override
  List<Object?> get props => [newCrypto];
}

class ExecuteSwapTransaction extends CryptoSwapEvent {
  final double targetGrossAmount;
  final bool isFiatToCrypto;

  const ExecuteSwapTransaction({
    required this.targetGrossAmount,
    required this.isFiatToCrypto,
  });

  @override
  List<Object?> get props => [targetGrossAmount, isFiatToCrypto];
}