import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/features/KYC/presentation/screens/biometric_setup_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/kyc_intro_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/kyc_verification_screen.dart';
import 'package:fintech/features/KYC/presentation/screens/pin_setup_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/forget_password_screen.dart';
import 'package:fintech/features/authentication/presentation/screens/set_username_screen.dart'; // ✅ Import set username screen
import 'package:go_router/go_router.dart';
import '../../../../features/authentication/presentation/screens/login_screen.dart';
import '../../../../features/authentication/presentation/screens/signup_screen.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String setUsername = '/set-username'; // ✅ Added route constant
  static const String kycIntro = '/kyc-intro';
  static const String pinSetup = '/pin-setup';
  static const String kycVerification = '/kyc-verify';
  static const String biometricSetup = '/biometric-setup';
  static const String forgotPassword = '/forgot-password';

  static List<RouteBase> get routes => [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRouter.signup,
          builder: (context, state) => const SignupScreen(),
        ),
        // ✅ Added GoRoute for SetUsernameScreen, passing userId as extra
        GoRoute(
          path: setUsername,
          builder: (context, state) {
            final userId = state.extra as String? ?? '';
            return SetUsernameScreen(userId: userId);
          },
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: biometricSetup,
          builder: (context, state) => const BiometricSetupScreen(),
        ),
        GoRoute(
          path: kycVerification,
          builder: (context, state) => const KycVerificationScreen(),
        ),

        GoRoute(path: kycIntro, builder: (context, state) => const KycIntroScreen()),
        GoRoute(path: pinSetup, builder: (context, state) => const PinSetupScreen()),
      ];
}