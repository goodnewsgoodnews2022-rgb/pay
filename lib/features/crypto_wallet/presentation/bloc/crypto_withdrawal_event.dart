import 'package:equatable/equatable.dart';

abstract class CryptoWithdrawalEvent extends Equatable {
  const CryptoWithdrawalEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user fills the form and requests a withdrawal payout
class ExecuteCryptoWithdrawal extends CryptoWithdrawalEvent {
  final String destinationAddress;
  final String networkCurrency; // 'usdtbsc' or 'usdttrx'
  final double amount;

  const ExecuteCryptoWithdrawal({
    required this.destinationAddress,
    required this.networkCurrency,
    required this.amount,
  });

  @override
  List<Object?> get props => [destinationAddress, networkCurrency, amount];
}

class ResetWithdrawalState extends CryptoWithdrawalEvent {}