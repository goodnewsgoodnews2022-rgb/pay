import 'package:equatable/equatable.dart';

abstract class CryptoSwapEvent extends Equatable {
  const CryptoSwapEvent();

  @override
  List<Object?> get props => [];
}

/// Toggles direction: true = Fiat to Crypto, false = Crypto to Fiat
class ToggleSwapDirection extends CryptoSwapEvent {}

/// Triggered dynamically as the user changes the text input amount
class CalculateSwapAmounts extends CryptoSwapEvent {
  final double inputAmount;

  const CalculateSwapAmounts({required this.inputAmount});

  @override
  List<Object?> get props => [inputAmount];
}

/// Executes the database exchange operation
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