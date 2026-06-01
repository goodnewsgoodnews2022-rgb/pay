// lib/main.dart

import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 1. Anchor framework engine channels before execution loops begin
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Prevent the app from drawing frames until initialization finishes completely
  widgetsBinding.deferFirstFrame();

  try {
    // 2. Load API credentials securely via your isolated environment configuration
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );

    // 3. Complete structural dependency registrations via GetIt locator
    setupDependencies();
    
    // Ensure getIt is entirely stabilized before rendering
    await getIt.allReady();

  } catch (e) {
    debugPrint('❌ [CRITICAL INITIALIZATION ERROR]: $e');
  } finally {
    // 4. Safely allow the framework engine to start drawing screen layout frames
    widgetsBinding.allowFirstFrame();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Lazily triggers lazy state evaluation after structural guarantees are locked in
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckStatus()),
        ),
        // Future global feature BLoCs (NotificationBloc, FiatWalletBloc, etc.) can be declared safely here
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        title: 'Pay Fintech',
        theme: AppTheme.darkTheme,
      ),
    );
  }
}