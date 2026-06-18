// import 'package:fintech/app/config/app_router.dart';
// import 'package:fintech/app/config/environment.dart';
// import 'package:fintech/core/theme/app_theme.dart';
// import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   // 1. Anchor framework engine channels before execution loops begin
//   final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
//   // Prevent the app from drawing layout frames until services are completely ready
//   widgetsBinding.deferFirstFrame();

//   try {
//     // 2. Load API credentials securely via your environment configurations
//     await Supabase.initialize(
//       url: Environment.supabaseUrl,
//       anonKey: Environment.supabaseAnonKey,
//     );

//     // 3. Complete structural dependency registrations via GetIt locator
//     // This now safely registers usecases, repositories, and your Splash features!
//     setupDependencies();
    
//     // Ensure getIt locator registries are entirely stabilized before rendering widgets
//     await getIt.allReady();

//   } catch (e) {
//     debugPrint('❌ [CRITICAL INITIALIZATION ERROR]: $e');
//   } finally {
//     // 4. Initialization complete—allow the framework to safely draw layout frames
//     widgetsBinding.allowFirstFrame();
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 🚀 CLEANUP: Removed MultiBlocProvider from here.
//     // The AppRouter's ShellRoute now manages scoped injections cleanly 
//     // to prevent ProviderNotFoundErrors and race conditions.
//     return MaterialApp.router(
//       routerConfig: AppRouter.router,
//       debugShowCheckedModeBanner: false,
//       title: 'Pay Fintech',
//       theme: AppTheme.darkTheme,
//     );
//   }
// }

import 'package:fintech/features/KYC/presentation/bloc/kyc_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/environment.dart';
import 'package:fintech/core/theme/app_theme.dart';
import 'package:fintech/features/authentication/presentation/bloc/bloc_dependency.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  widgetsBinding.deferFirstFrame();

  try {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
    setupDependencies();
    await getIt.allReady();
  } catch (e) {
    debugPrint('❌ [CRITICAL INITIALIZATION ERROR]: $e');
  } finally {
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
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()
            ..add(
              AuthCheckStatus(),
            ), // Ensure AuthCheckStatus event exists
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
        ),
        BlocProvider<KycBloc>(create: (_) => getIt<KycBloc>()),
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
