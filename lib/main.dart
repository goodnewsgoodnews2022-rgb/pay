// lib/main.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Added
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// ... all your existing imports
import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';
import 'package:fintech/features/KYC/presentation/bloc/kyc_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_state.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fintech/admin/presentation/bloc/admin_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final themeStateProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  widgetsBinding.deferFirstFrame();

  try {
    Environment.validate();
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint("❌ Supabase Init Error: $e");
  }

  try {
    await setupDependencies();
    await getIt.allReady();
  } catch (e) {
    debugPrint("❌ Dependency Injection Error: $e");
  } finally {
    widgetsBinding.allowFirstFrame();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeStateProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()..add(AuthCheckStatus())),
        BlocProvider<NotificationBloc>(create: (_) => getIt<NotificationBloc>()),
        BlocProvider<KycBloc>(create: (_) => getIt<KycBloc>()),
        BlocProvider<AdminBloc>(create: (_) => getIt<AdminBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            AppRouter.router.go('/login');
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "Pay Fintech",
          routerConfig: AppRouter.router,
          
          // ✅ PROFESSIONAL FIX: Apply Google Fonts to the text theme
          // This forces the app to use a font that supports the ₦ symbol
          theme: AppTheme.lightTheme?.copyWith(
            textTheme: GoogleFonts.notoSansTextTheme(AppTheme.lightTheme?.textTheme),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            textTheme: GoogleFonts.notoSansTextTheme(AppTheme.darkTheme.textTheme),
          ),
          
          themeMode: currentThemeMode,
        ),
      ),
    );
  }
}