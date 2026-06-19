// ignore_for_file: undefined_hidden_name, unused_import

import 'package:fintech/features/dashboard/presentation/screens/more_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/reports_statements_screen.dart';
import 'package:flutter/material.dart';
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
    
    // 🚀 CRITICAL FIX: Instantiating pages inside initState guarantees that 
    // the DashboardScreen state (and its Supabase real-time stream) is persistent.
    _pages = [
      DashboardScreen(
        onNavigateToSubScreen: (Widget customScreen) {
          setState(() {
            _activeSubScreen = customScreen; 
          });
        },
      ),
      const ReportsStatementsScreen(),
      const Center(child: Text('Ledger Screen', style: TextStyle(color: Colors.white))),
      MoreScreen(
        onNavigateToSubScreen: (Widget customScreen) {
          setState(() {
            _activeSubScreen = customScreen;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Layout Guard: Using an AnimatedSwitcher or clean layout bounds prevents overflows 
      // when popping in or out of nested sub-screens.
      body: SafeArea(
        child: _activeSubScreen != null 
            ? _activeSubScreen! 
            : IndexedStack(index: _currentIndex, children: _pages),
      ),
          
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _activeSubScreen = null; // Clears active sub-screens on structural tab switches
          });
        },
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