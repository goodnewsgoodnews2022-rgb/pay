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
  Widget? _activeSubScreen; 

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final List<Widget> _pages = [
      DashboardScreen(
        onNavigateToSubScreen: (Widget customScreen) {
          setState(() {
            _activeSubScreen = customScreen; 
          });
        },
      ),
      const AnalysisScreen(),
      const TransactionLedgerScreen(),
      const SettingsScreen(), // This is where your nested settings configuration views live
    ];

    return Scaffold(
      body: _activeSubScreen != null 
          ? _activeSubScreen! 
          : IndexedStack(index: _currentIndex, children: _pages),
          
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _activeSubScreen = null; // Clears active action screen states automatically
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        // 🚀 Updated labels and icons according to mentor feedback for professional optimization
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