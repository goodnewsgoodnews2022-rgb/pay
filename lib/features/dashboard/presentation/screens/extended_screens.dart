import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('Analytics & Spending Insights Screen', style: TextStyle(color: Colors.white, fontSize: 18))),
    );
  }
}

class TransactionLedgerScreen extends StatelessWidget {
  const TransactionLedgerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('Unified Fiat & Web3 Ledger Stream', style: TextStyle(color: Colors.white, fontSize: 18))),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('User App Configurations & Security Settings', style: TextStyle(color: Colors.white, fontSize: 18))),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('Personal Profile Settings Screen', style: TextStyle(color: Colors.white, fontSize: 18))),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const NotificationScreen();
  }
}

class CustomerCareScreen extends StatelessWidget {
  const CustomerCareScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('24/7 Customer Care & Help Support', style: TextStyle(color: Colors.white, fontSize: 18))),
    );
  }
}

// Action placeholders
class ActionPlaceholderScreen extends StatelessWidget {
  final String title;
  const ActionPlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: Text('$title Execution Portal', style: const TextStyle(color: Colors.white, fontSize: 18))),
    );
  }
}