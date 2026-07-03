// ignore_for_file: undefined_hidden_name, unused_import

import 'package:fintech/features/dashboard/presentation/screens/more_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/analysis_screen.dart'; // ✅ Updated to match your new Analysis screen
import 'package:fintech/features/dashboard/presentation/screens/ledger_screen.dart';   // ✅ Updated to match your new Ledger screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🚀 CRITICAL FOR ROUTING TO FUNCTION
import 'dashboard_screen.dart';
import 'extended_screens.dart' hide SettingsScreen, DashboardScreen;
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;
  Widget? _activeSubScreen; 
  late final List<Widget> _pages; // 🛡️ Cached references to prevent state teardowns

  @override
  void initState() {
    super.initState();
    
    // 🚀 THE REAL UI SCREENS LINKED HERE
    _pages = [
      DashboardScreen(
        onNavigateToSubScreen: (Widget customScreen) {
          setState(() {
            _activeSubScreen = customScreen; 
          });
        },
      ),
      const AnalysisScreen(), // ✅ Swapped your old placeholder for the premium chart dashboard
      const LedgerScreen(),   // ✅ Swapped the white text widget for your official ledger database table
      MoreScreen(
        onNavigateToSubScreen: (Widget customScreen) {
          setState(() {
            _activeSubScreen = customScreen;
          });
        },
      ),
    ];
  }

  // 🔄 Syncs bottom tab bar highlight with browser URL state updates
  void _syncRouteToTab(int index) {
    setState(() {
      _currentIndex = index;
      _activeSubScreen = null; // Clears active sub-screens on structural tab switches
    });

    // 🚀 ROUTE PATH ENFORCEMENT
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/reports-statements'); // Navigates to Analysis route path
        break;
      case 2:
        context.go('/ledger'); // Navigates to Ledger route path
        break;
      case 3:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _activeSubScreen != null 
            ? _activeSubScreen! 
            : IndexedStack(index: _currentIndex, children: _pages),
      ),
          
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _syncRouteToTab, // ✅ Connected routing controller here
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Ledger'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}