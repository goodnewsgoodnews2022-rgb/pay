import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'extended_screens.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});
  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;
  Widget? _activeSubScreen; // Tracks current inner utility page context

  @override
  Widget build(BuildContext context) {
    // Standard view matrix pages map
    // ignore: no_leading_underscores_for_local_identifiers
    final List<Widget> _pages = [
      DashboardScreen(
        onNavigateToSubScreen: (Widget customScreen) {
          setState(() {
            _activeSubScreen = customScreen; // Sets the explicit overlay state layer
          });
        },
      ),
      const AnalysisScreen(),
      const TransactionLedgerScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      // If a sub screen is selected, render it inside the workspace view layer, 
      // otherwise fallback directly to your IndexedStack setup configuration
      body: _activeSubScreen != null 
          ? _activeSubScreen! 
          : IndexedStack(index: _currentIndex, children: _pages),
          
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _activeSubScreen = null; // 🚀 CRITICAL FIX: Instantly clears the sub-view back to dashboard
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
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Ledger/Me'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}