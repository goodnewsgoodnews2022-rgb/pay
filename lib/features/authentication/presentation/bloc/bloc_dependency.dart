import 'package:get_it/get_it.dart';
import '../../data/datasources/models/repositories/auth_repository_impl.dart';
import '../../domain/entities/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import 'auth_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Repository
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  
  // Usecases
  getIt.registerLazySingleton(() => SignUp(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SendPasswordReset(getIt<AuthRepository>()));
  
  // Bloc
  getIt.registerFactory(() => AuthBloc(
    signUp: getIt(),
    signIn: getIt(),
    signOut: getIt(),
    getCurrentUser: getIt(),
    sendPasswordReset: getIt(),
  ));
}