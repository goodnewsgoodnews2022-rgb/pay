// lib/app/app.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'config/app_router.dart';
import 'config/environment.dart';
import '../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Imported your brand new unified theme compiler

class FintechApp extends StatefulWidget {
  const FintechApp({super.key});

  @override
  State<FintechApp> createState() => _FintechAppState();
}

class _FintechAppState extends State<FintechApp> {
  @override
  void initState() {
    super.initState();
    // Validate configuration safety parameters immediately upon boot sequence
    Environment.validate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Premium Multi-Currency Engine',
      debugShowCheckedModeBanner: false,
      
      // 2. CLEANED UP: Replaced the massive ThemeData block with your centralized engine instance
      theme: AppTheme.darkTheme,
      
      // Hook up your global GoRouter configuration grid
      routerConfig: AppRouter.router,
    );
  }
}