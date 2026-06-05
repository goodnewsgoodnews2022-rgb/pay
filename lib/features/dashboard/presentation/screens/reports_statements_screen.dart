import 'package:flutter/material.dart';

class ReportsStatementsScreen extends StatelessWidget {
  const ReportsStatementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(title: const Text('Reports & Statements'), backgroundColor: const Color(0xFF0A0E17)),
      body: const Center(child: Text('Statements Page', style: TextStyle(color: Colors.white))),
    );
  }
}