import 'package:go_router/go_router.dart';
import '../../../../features/authentication/presentation/screens/login_screen.dart';
import '../../../../features/authentication/presentation/screens/signup_screen.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String signup = '/signup';

  static List<RouteBase> get routes => [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: signup,
          builder: (context, state) => const SignupScreen(),
        ),
      ];
}