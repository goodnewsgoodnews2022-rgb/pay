import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/crypto_api_client.dart';
import 'crypto_wallet_event.dart';
import 'crypto_wallet_state.dart';

class CryptoWalletBloc extends Bloc<CryptoWalletEvent, CryptoWalletState> {
  final CryptoApiClient _apiClient;

  CryptoWalletBloc({required CryptoApiClient apiClient})
      : _apiClient = apiClient,
        super(CryptoWalletInitial()) {
          
    on<GenerateDepositAddress>((event, emit) async {
      emit(CryptoWalletLoading());
      try {
        final paymentModel = await _apiClient.createDepositInvoice(
          amount: event.amount,
          currency: event.networkCurrency,
        );
        emit(CryptoWalletAddressGenerated(paymentDetails: paymentModel));
      } catch (e) {
        emit(CryptoWalletError(errorMessage: e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ResetCryptoWalletState>((event, emit) {
      emit(CryptoWalletInitial());
    });
  }
}