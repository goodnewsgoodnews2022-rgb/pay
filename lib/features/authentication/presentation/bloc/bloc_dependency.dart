// ignore_for_file: depend_on_referenced_packages
import 'package:fintech/admin/data/repositories/admin_repository_impl.dart';
import 'package:fintech/admin/domain/repositories/admin_repository.dart';
import 'package:fintech/admin/domain/usecases/approve_kyc.dart';
import 'package:fintech/admin/domain/usecases/get_all_user.dart';
import 'package:fintech/admin/domain/usecases/get_dashboard_stats.dart';
import 'package:fintech/admin/domain/usecases/get_transaction.dart';
import 'package:fintech/admin/domain/usecases/reject_kyc.dart';
import 'package:fintech/admin/domain/usecases/send_broadcast_notification.dart';
import 'package:fintech/admin/domain/usecases/update_user_status.dart';
import 'package:fintech/admin/presentation/bloc/admin_bloc.dart';
import 'package:fintech/features/KYC/data/datasources/biometric_local_ds.dart';
import 'package:fintech/features/KYC/data/datasources/pin_local_ds.dart';
import 'package:fintech/features/KYC/data/repositories/kyc_repositories_impl.dart';
import 'package:fintech/features/KYC/domain/repositories/kyc_repository.dart';
import 'package:fintech/features/KYC/domain/usecases/authenticate_with_biometric.dart';
import 'package:fintech/features/KYC/domain/usecases/check_biometric_support.dart';
import 'package:fintech/features/KYC/domain/usecases/get_kyc_status.dart';
import 'package:fintech/features/KYC/domain/usecases/set_pin.dart';
import 'package:fintech/features/KYC/domain/usecases/update_kyc_status.dart';
import 'package:fintech/features/KYC/domain/usecases/verify_pin.dart';
import 'package:fintech/features/KYC/presentation/bloc/kyc_bloc.dart';
import 'package:fintech/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:fintech/features/fiat_wallet/data/repositories/fiat_repository_impl.dart';
import 'package:fintech/features/fiat_wallet/domain/repositories/fiat_repository.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/deposit_funds.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/get_fiat_balances.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/get_transaction_history.dart';
import 'package:fintech/features/fiat_wallet/domain/usecases/withdraw_funds.dart';
import 'package:fintech/features/fiat_wallet/presentation/bloc/fiat_wallet_bloc.dart';
import 'package:fintech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fintech/features/notifications/domain/repositories/notification_repository_impl.dart';
import 'package:fintech/features/notifications/domain/usecase/fetch_notification.dart';
import 'package:fintech/features/notifications/domain/usecase/get_unread_count.dart';
import 'package:fintech/features/notifications/domain/usecase/mark_all_as_read.dart';
import 'package:fintech/features/notifications/domain/usecase/mark_as_read.dart';
import 'package:fintech/features/notifications/domain/usecase/subscribe_to_notification.dart';
import 'package:fintech/features/notifications/domain/usecase/delete_notification.dart';
import 'package:fintech/features/notifications/domain/usecase/delete_all_notifications.dart';
import 'package:fintech/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fintech/features/settings/domain/usecases/update_theme.dart';
import 'package:fintech/features/settings/domain/usecases/toggle_biometrics.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Splash Feature Modules ---
import 'package:fintech/features/splash/data/datasources.dart';
import 'package:fintech/features/splash/presentation/splash_navigation_cubit.dart';

// --- Settings Clean Architecture Feature Modules ---
import '../../../settings/data/datasources/settings_local_data_source.dart';
import '../../../settings/data/repositories/settings_repository_impl.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

// --- Authentication Clean Architecture Core Imports ---
import '../../data/datasources/models/repositories/auth_repository_impl.dart';
import '../../domain/entities/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import 'auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ====================================================================
  // ⚡ CORE INFRASTRUCTURE CONFIGURATIONS
  // ====================================================================
  if (!getIt.isRegistered<SupabaseClient>()) {
    getIt.registerLazySingleton<SupabaseClient>(
      () => Supabase.instance.client,
    );
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(
      () => sharedPreferences,
    );
  }

  // ====================================================================
  // ⚙️ SETTINGS CLEAN ARCHITECTURE FEATURE MODULE
  // ====================================================================
  if (!getIt.isRegistered<SettingsLocalDataSource>()) {
    getIt.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<SettingsRepository>()) {
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<SettingsLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<ToggleBiometrics>()) {
    getIt.registerLazySingleton(
      () => ToggleBiometrics(getIt<SettingsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateTheme>()) {
    getIt.registerLazySingleton(
      () => UpdateTheme(getIt<SettingsRepository>()),
    );
  }

  if (!getIt.isRegistered<SettingsBloc>()) {
    getIt.registerFactory(
      () => SettingsBloc(
        repository: getIt<SettingsRepository>(),
        toggleBiometrics: getIt<ToggleBiometrics>(),
        updateTheme: getIt<UpdateTheme>(),
      ),
    );
  }

  // ====================================================================
  // 🛡️ SPLASH GATEWAY FEATURE MODULE
  // ====================================================================
  if (!getIt.isRegistered<SessionLocalCheck>()) {
    getIt.registerLazySingleton<SessionLocalCheck>(
      () => SessionLocalCheckImpl(getIt<SupabaseClient>()),
    );
  }

  if (!getIt.isRegistered<SplashNavigationCubit>()) {
    getIt.registerFactory<SplashNavigationCubit>(
      () => SplashNavigationCubit(getIt<SessionLocalCheck>()),
    );
  }

  // ====================================================================
  // 🔑 AUTHENTICATION CLEAN ARCHITECTURE CORE
  // ====================================================================
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(),
    );
  }

  if (!getIt.isRegistered<SignUp>()) {
    getIt.registerLazySingleton(() => SignUp(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<SignIn>()) {
    getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<SignOut>()) {
    getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<GetCurrentUser>()) {
    getIt.registerLazySingleton(
      () => GetCurrentUser(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SendPasswordReset>()) {
    getIt.registerLazySingleton(
      () => SendPasswordReset(getIt<AuthRepository>()),
    );
  }

  // ✅ Register Google Sign‑In usecase
  if (!getIt.isRegistered<SignInWithGoogle>()) {
    getIt.registerLazySingleton(
      () => SignInWithGoogle(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        signUp: getIt<SignUp>(),
        signIn: getIt<SignIn>(),
        signOut: getIt<SignOut>(),
        getCurrentUser: getIt<GetCurrentUser>(),
        sendPasswordReset: getIt<SendPasswordReset>(),
        signInWithGoogle: getIt<SignInWithGoogle>(),
      ),
    );
  }

  // ====================================================================
  // 🔔 NOTIFICATIONS FEATURE MODULE
  // ====================================================================
  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(),
    );
  }

  if (!getIt.isRegistered<FetchNotifications>()) {
    getIt.registerLazySingleton(
      () => FetchNotifications(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<MarkAsRead>()) {
    getIt.registerLazySingleton(
      () => MarkAsRead(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<MarkAllAsRead>()) {
    getIt.registerLazySingleton(
      () => MarkAllAsRead(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<GetUnreadCount>()) {
    getIt.registerLazySingleton(
      () => GetUnreadCount(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<SubscribeToNotifications>()) {
    getIt.registerLazySingleton(
      () => SubscribeToNotifications(getIt<NotificationRepository>()),
    );
  }

  // ✅ Register DeleteNotification and DeleteAllNotifications (fixed)
  if (!getIt.isRegistered<DeleteNotification>()) {
    getIt.registerLazySingleton(
      () =>
          DeleteNotification(getIt<NotificationRepository>()), // ✅ no cast
    );
  }
  if (!getIt.isRegistered<DeleteAllNotifications>()) {
    getIt.registerLazySingleton(
      () => DeleteAllNotifications(
        getIt<NotificationRepository>(),
      ), // ✅ fixed
    );
  }

  // ✅ Register NotificationBloc with all dependencies
  if (!getIt.isRegistered<NotificationBloc>()) {
    getIt.registerFactory(
      () => NotificationBloc(
        fetchNotifications: getIt<FetchNotifications>(),
        markAsRead: getIt<MarkAsRead>(),
        markAllAsRead: getIt<MarkAllAsRead>(),
        getUnreadCount: getIt<GetUnreadCount>(),
        subscribeToNotifications: getIt<SubscribeToNotifications>(),
        deleteNotification: getIt<DeleteNotification>(),
        deleteAllNotifications: getIt<DeleteAllNotifications>(),
      ),
    );
  }

  // ====================================================================
  // 💼 FIAT WALLET FEATURE DEPENDENCIES
  // ====================================================================
  if (!getIt.isRegistered<FiatRepository>()) {
    getIt.registerLazySingleton<FiatRepository>(
      () => FiatRepositoryImpl(),
    );
  }
  if (!getIt.isRegistered<GetFiatBalances>()) {
    getIt.registerLazySingleton(
      () => GetFiatBalances(getIt<FiatRepository>()),
    );
  }
  if (!getIt.isRegistered<DepositFunds>()) {
    getIt.registerLazySingleton(
      () => DepositFunds(getIt<FiatRepository>()),
    );
  }
  if (!getIt.isRegistered<WithdrawFunds>()) {
    getIt.registerLazySingleton(
      () => WithdrawFunds(getIt<FiatRepository>()),
    );
  }
  if (!getIt.isRegistered<GetTransactionHistory>()) {
    getIt.registerLazySingleton(
      () => GetTransactionHistory(getIt<FiatRepository>()),
    );
  }

  if (!getIt.isRegistered<FiatWalletBloc>()) {
    getIt.registerFactory(
      () => FiatWalletBloc(
        getFiatBalances: getIt(),
        depositFunds: getIt(),
        withdrawFunds: getIt(),
        getTransactionHistory: getIt(),
      ),
    );
  }

  // ====================================================================
  // 🪪 KYC CLEAN ARCHITECTURE MODULE
  // ====================================================================
  if (!getIt.isRegistered<BiometricLocalDataSource>()) {
    getIt.registerLazySingleton(() => BiometricLocalDataSource());
  }
  if (!getIt.isRegistered<PinLocalDataSource>()) {
    getIt.registerLazySingleton(() => PinLocalDataSource());
  }
  if (!getIt.isRegistered<KycRepository>()) {
    getIt.registerLazySingleton<KycRepository>(
      () => KycRepositoryImpl(biometricDS: getIt(), pinDS: getIt()),
    );
  }
  if (!getIt.isRegistered<CheckBiometricSupport>()) {
    getIt.registerLazySingleton(
      () => CheckBiometricSupport(getIt<KycRepository>()),
    );
  }
  if (!getIt.isRegistered<AuthenticateWithBiometric>()) {
    getIt.registerLazySingleton(
      () => AuthenticateWithBiometric(getIt<KycRepository>()),
    );
  }
  if (!getIt.isRegistered<SetPin>()) {
    getIt.registerLazySingleton(() => SetPin(getIt<KycRepository>()));
  }
  if (!getIt.isRegistered<VerifyPin>()) {
    getIt.registerLazySingleton(() => VerifyPin(getIt<KycRepository>()));
  }
  if (!getIt.isRegistered<GetKycStatus>()) {
    getIt.registerLazySingleton(
      () => GetKycStatus(getIt<KycRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateKycStatus>()) {
    getIt.registerLazySingleton(
      () => UpdateKycStatus(getIt<KycRepository>()),
    );
  }
  if (!getIt.isRegistered<KycBloc>()) {
    getIt.registerFactory(
      () => KycBloc(
        checkBiometricSupport: getIt(),
        authenticateWithBiometric: getIt(),
        setPin: getIt(),
        verifyPin: getIt(),
        getKycStatus: getIt(),
        updateKycStatus: getIt(),
      ),
    );
  }

  // ====================================================================
  // 👑 ADMIN DASHBOARD FEATURE
  // ====================================================================
  if (!getIt.isRegistered<AdminRepository>()) {
    getIt.registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(),
    );
  }
  if (!getIt.isRegistered<GetDashboardStats>()) {
    getIt.registerLazySingleton(
      () => GetDashboardStats(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<GetAllUsers>()) {
    getIt.registerLazySingleton(
      () => GetAllUsers(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateUserStatus>()) {
    getIt.registerLazySingleton(
      () => UpdateUserStatus(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<ApproveKyc>()) {
    getIt.registerLazySingleton(
      () => ApproveKyc(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<RejectKyc>()) {
    getIt.registerLazySingleton(() => RejectKyc(getIt<AdminRepository>()));
  }
  if (!getIt.isRegistered<GetTransactions>()) {
    getIt.registerLazySingleton(
      () => GetTransactions(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<SendBroadcastNotification>()) {
    getIt.registerLazySingleton(
      () => SendBroadcastNotification(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminBloc>()) {
    getIt.registerFactory(
      () => AdminBloc(
        getDashboardStats: getIt(),
        getAllUsers: getIt(),
        updateUserStatus: getIt<UpdateUserStatus>(),
        approveKyc: getIt(),
        rejectKyc: getIt(),
        getTransactions: getIt(),
        sendBroadcastNotification: getIt(),
      ),
    );
  }
}
