// ignore_for_file: prefer_const_constructors, unused_import

import 'package:fintech/app/app.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
  setupDependencies();  // registers AuthBloc and others with GetIt

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckStatus())),
        // Add other blocs later (NotificationBloc, FiatWalletBloc, etc.)
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,  // your GoRouter instance
        title: 'Fintech App',
        theme: AppTheme.darkTheme,
      ),
    );
  }
}