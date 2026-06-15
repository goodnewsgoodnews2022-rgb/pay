import 'package:equatable/equatable.dart';
import '../../data/models/crypto_payment_model.dart';

abstract class CryptoWalletState extends Equatable {
  const CryptoWalletState();

  @override
  List<Object?> get props => [];
}

class CryptoWalletInitial extends CryptoWalletState {}

class CryptoWalletLoading extends CryptoWalletState {}

class CryptoWalletAddressGenerated extends CryptoWalletState {
  final CryptoPaymentModel paymentDetails;

  const CryptoWalletAddressGenerated({required this.paymentDetails});

  @override
  List<Object?> get props => [paymentDetails];
}

class CryptoWalletError extends CryptoWalletState {
  final String errorMessage;

  const CryptoWalletError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}