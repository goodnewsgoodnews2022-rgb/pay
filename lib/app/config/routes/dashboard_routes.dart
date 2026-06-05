// ignore_for_file: unrelated_type_equality_checks, unused_import

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core Dashboard Component View Imports
import '../../../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../../features/crypto_wallet/presentation/screens/crypto_wallet_screen.dart';
import '../../../../../features/settings/presentation/screens/settings_screen.dart';

// 💵 Add Money Core Feature Screens & Sub-Gateways
import '../../../../../features/dashboard/presentation/screens/add_money_screen.dart';
// Note: Create empty placeholder files for these sub-screens if they aren't generated yet!
// Sub-screens imports removed due to missing files. Using Placeholder() in routes.

class DashboardRoutes {
  static const String dashboard = '/dashboard';
  static const String wallet = '/wallet';
  static const String settings = '/settings';
  
  // Explicit location constant tracking path for the Add Money sub-root
  static const String addMoney = 'add-money';

  static List<RouteBase> get routes => [
        GoRoute(
          path: dashboard,
          builder: (context, state) => DashboardScreen(
            onNavigateToSubScreen: (index) => context.go(index == 1 ? wallet : settings),
          ),
          routes: [
            // ====================================================================
            // 💵 ADD MONEY ROUTING SUBSYSTEM (Nested under /dashboard)
            // ====================================================================
            GoRoute(
              path: addMoney, // Maps cleanly to context.push('/dashboard/add-money')
              builder: (context, state) => const AddMoneyScreen(),
              routes: [
                GoRoute(
                  path: 'bank-transfer-details',
                  builder: (context, state) => const Placeholder(),
                ),
                GoRoute(
                  path: 'cash-deposit',
                  builder: (context, state) => const Placeholder(),
                ),
                GoRoute(
                  path: 'card-topup',
                  builder: (context, state) => const Placeholder(),
                ),
                GoRoute(
                  path: 'bank-ussd',
                  builder: (context, state) => const Placeholder(),
                ),
                GoRoute(
                  path: 'scan-qr',
                  builder: (context, state) => const Placeholder(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: wallet,
          builder: (context, state) => const CryptoWalletScreen(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ];
}