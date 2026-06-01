// lib/features/splash/presentation/controllers/splash_navigation_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasources.dart';
import 'controllers.dart';

class SplashNavigationCubit extends Cubit<SplashNavigationState> {
  final SessionLocalCheck _sessionCheck;

  SplashNavigationCubit(this._sessionCheck) : super(SplashInitial());

  /// Coordinates app initial state tracking to pick the exact routing terminal point
  Future<void> initializeAppGatewaySequence() async {
    emit(SplashEvaluatingState());
    
    // 1. Give branding text/animations a minimum display window
    await Future.delayed(const Duration(seconds: 2));

    // 2. Run backend and hardware device token inspections
    final bool hasValidSession = _sessionCheck.isServerSessionValid();
    final bool requiresBiometrics = await _sessionCheck.isBiometricAuthEnabled();

    // 3. Emit matching navigation targets cleanly
    if (!hasValidSession) {
      emit(NavigateToLogin());
    } else if (requiresBiometrics) {
      emit(NavigateToBiometricVerification());
    } else {
      emit(NavigateToDashboard());
    }
  }
}