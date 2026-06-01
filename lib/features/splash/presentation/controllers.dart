// lib/features/splash/presentation/controllers/splash_navigation_state.dart

abstract class SplashNavigationState {
  const SplashNavigationState();
}

class SplashInitial extends SplashNavigationState {}
class SplashEvaluatingState extends SplashNavigationState {}
class NavigateToLogin extends SplashNavigationState {}
class NavigateToDashboard extends SplashNavigationState {}
class NavigateToBiometricVerification extends SplashNavigationState {}