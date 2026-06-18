import 'package:flutter_bloc/flutter_bloc.dart';
import 'crypto_swap_event.dart';
import 'crypto_swap_state.dart';

class CryptoSwapBloc extends Bloc<CryptoSwapEvent, CryptoSwapState> {
  CryptoSwapBloc() : super(CryptoSwapState.initial()) {
    
    on<ToggleSwapDirection>((event, emit) {
      emit(state.copyWith(
        isFiatToCrypto: !state.isFiatToCrypto,
        inputAmount: 0.0,
        platformFee: 0.0,
        outputAmount: 0.0,
        isSuccess: false,
      ));
    });

    on<CalculateSwapAmounts>((event, emit) {
      final gross = event.inputAmount;
      final fee = gross * 0.01; // mentor's 1% platform algorithm
      final netOutput = gross - fee;

      emit(state.copyWith(
        inputAmount: gross,
        platformFee: fee,
        outputAmount: netOutput,
        isSuccess: false,
      ));
    });

    on<ChangeFiatCurrency>((event, emit) {
      emit(state.copyWith(selectedFiat: event.newFiat, isSuccess: false));
    });

    on<ChangeCryptoCurrency>((event, emit) {
      emit(state.copyWith(selectedCrypto: event.newCrypto, isSuccess: false));
    });

    on<ExecuteSwapTransaction>((event, emit) async {
      emit(state.copyWith(isLoading: true, isSuccess: false));
      try {
        await Future.delayed(const Duration(milliseconds: 1200));
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });
  }
}