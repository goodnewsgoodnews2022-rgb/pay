import 'package:flutter_bloc/flutter_bloc.dart';
import 'crypto_swap_event.dart';
import 'crypto_swap_state.dart';

class CryptoSwapBloc extends Bloc<CryptoSwapEvent, CryptoSwapState> {
  CryptoSwapBloc() : super(CryptoSwapState.initial()) {
    
    // Handles swapping the source and target rails
    on<ToggleSwapDirection>((event, emit) {
      emit(state.copyWith(
        isFiatToCrypto: !state.isFiatToCrypto,
        inputAmount: 0.0,
        platformFee: 0.0,
        outputAmount: 0.0,
        isSuccess: false,
      ));
    });

    // Calculates your mentor's 1% processing fee equation live
    on<CalculateSwapAmounts>((event, emit) {
      final gross = event.inputAmount;
      final fee = gross * 0.01; // 1% SaaS deduction fee rule
      final netOutput = gross - fee;

      emit(state.copyWith(
        inputAmount: gross,
        platformFee: fee,
        outputAmount: netOutput,
        isSuccess: false,
      ));
    });

    // Submits the execution state down to local balances
    on<ExecuteSwapTransaction>((event, emit) async {
      emit(state.copyWith(isLoading: true, isSuccess: false));
      try {
        // Simulating rapid state engine validation
        await Future.delayed(const Duration(milliseconds: 1200));
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });
  }
}