// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Config & Theme Imports
import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';

// Bloc Imports
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:fintech/features/notifications/presentation/bloc/notification_bloc.dart';

// 🚀 Your Riverpod Theme Provider
final themeStateProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

void main() async {
  // 1. Anchor framework engine channels before execution loops begin
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Prevent the app from drawing layout frames until services are completely ready
  widgetsBinding.deferFirstFrame();

  try {
    // 2. Load API credentials securely via your environment configurations
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );

    // 3. Complete structural dependency registrations via GetIt locator
    setupDependencies();
    
    // Ensure getIt locator registries are entirely stabilized before rendering widgets
    await getIt.allReady();

  } catch (e) {
    debugPrint('❌ [CRITICAL INITIALIZATION ERROR]: $e');
  } finally {
    // 4. Initialization complete—allow the framework to safely draw layout frames
    widgetsBinding.allowFirstFrame();
  }

  runApp(
    // ✅ FIX 1: Wrap the entire app in Riverpod's ProviderScope so preferences work!
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ✅ FIX 2: Changed back to ConsumerWidget so Riverpod can listen to your theme state
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👁️ Watch your active theme selection state dynamically
    final currentThemeMode = ref.watch(themeStateProvider);

    // ✅ FIX 3: Nest your teammate's MultiBlocProvider right inside your widget tree
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckStatus()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        title: 'Pay Fintech',
        
        // Your theme properties preserved
        theme: AppTheme.lightTheme, 
        darkTheme: AppTheme.darkTheme,
        themeMode: currentThemeMode,
      ),
    );
  }
}