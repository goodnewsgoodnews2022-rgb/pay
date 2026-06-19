import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/crypto_api_client.dart';
import 'crypto_withdrawal_event.dart';
import 'crypto_withdrawal_state.dart';

class CryptoWithdrawalBloc extends Bloc<CryptoWithdrawalEvent, CryptoWithdrawalState> {
  final CryptoApiClient _apiClient;

  CryptoWithdrawalBloc({required CryptoApiClient apiClient})
      : _apiClient = apiClient,
        super(CryptoWithdrawalInitial()) {
          
    on<ExecuteCryptoWithdrawal>((event, emit) async {
      emit(CryptoWithdrawalLoading());
      try {
        final result = await _apiClient.createWithdrawal(
          targetAddress: event.destinationAddress,
          currency: event.networkCurrency,
          grossAmount: event.amount,
        );
        emit(CryptoWithdrawalSuccess(withdrawalDetails: result));
      } catch (e) {
        emit(CryptoWithdrawalError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    });

    on<ResetWithdrawalState>((event, emit) {
      emit(CryptoWithdrawalInitial());
    });
  }
}