// lib/main.dart

import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 1. Anchor framework engine channels before execution loops begin
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Prevent the app from drawing layout frames until services are ready
  widgetsBinding.deferFirstFrame();

  try {
    // 2. Load API credentials securely via your environment configurations
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );

    // 3. Complete structural dependency registrations via GetIt locator
    // This now safely registers usecases, repositories, and your Splash features!
    setupDependencies();
    
    // Ensure getIt is entirely stabilized before rendering widgets
    await getIt.allReady();

  } catch (e) {
    debugPrint('❌ [CRITICAL INITIALIZATION ERROR]: $e');
  } finally {
    // 4. Initialization complete—allow the framework to draw layout frames
    widgetsBinding.allowFirstFrame();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 CLEANUP: Removed MultiBlocProvider from here.
    // The AppRouter's ShellRoute now manages scoped injections cleanly 
    // to prevent ProviderNotFoundErrors and race conditions.
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'Pay Fintech',
      theme: AppTheme.darkTheme,
    );
  }
}