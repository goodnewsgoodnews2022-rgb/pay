import 'package:equatable/equatable.dart';

class CryptoSwapState extends Equatable {
  final bool isFiatToCrypto;
  final double inputAmount;
  final double platformFee;
  final double outputAmount;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const CryptoSwapState({
    required this.isFiatToCrypto,
    required this.inputAmount,
    required this.platformFee,
    required this.outputAmount,
    required this.isLoading,
    this.errorMessage,
    required this.isSuccess,
  });

  factory CryptoSwapState.initial() {
    return const CryptoSwapState(
      isFiatToCrypto: true, // Default: Fiat -> Crypto
      inputAmount: 0.0,
      platformFee: 0.0,
      outputAmount: 0.0,
      isLoading: false,
      errorMessage: null,
      isSuccess: false,
    );
  }

  CryptoSwapState copyWith({
    bool? isFiatToCrypto,
    double? inputAmount,
    double? platformFee,
    double? outputAmount,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CryptoSwapState(
      isFiatToCrypto: isFiatToCrypto ?? this.isFiatToCrypto,
      inputAmount: inputAmount ?? this.inputAmount,
      platformFee: platformFee ?? this.platformFee,
      outputAmount: outputAmount ?? this.outputAmount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isFiatToCrypto,
        inputAmount,
        platformFee,
        outputAmount,
        isLoading,
        errorMessage,
        isSuccess,
      ];
}