// lib/app/config/routes/wallet_routes.dart

// ignore_for_file: unused_import, duplicate_import

import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Replace these placeholders with the actual relative paths to your team's screens
import '../../../../features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart'; 

class WalletRoutes {
  static const String wallet = '/wallet';

  static List<RouteBase> get routes => [
        GoRoute(
          path: wallet,
          builder: (context, state) {
            // Optional: You can extract route parameters securely right here 
            // e.g., final tokenType = state.uri.queryParameters['type'];
            return const CryptoWalletScreen();
          },
        ),
      ];
}