import 'package:equatable/equatable.dart';
import '../../data/models/crypto_withdrawal_model.dart';

abstract class CryptoWithdrawalState extends Equatable {
  const CryptoWithdrawalState();

  @override
  List<Object?> get props => [];
}

class CryptoWithdrawalInitial extends CryptoWithdrawalState {}

class CryptoWithdrawalLoading extends CryptoWithdrawalState {}

class CryptoWithdrawalSuccess extends CryptoWithdrawalState {
  final CryptoWithdrawalModel withdrawalDetails;

  const CryptoWithdrawalSuccess({required this.withdrawalDetails});

  @override
  List<Object?> get props => [withdrawalDetails];
}

class CryptoWithdrawalError extends CryptoWithdrawalState {
  final String errorMessage;

  const CryptoWithdrawalError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}