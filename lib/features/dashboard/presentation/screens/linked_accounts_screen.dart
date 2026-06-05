import 'package:flutter/material.dart';

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(title: const Text('Linked Accounts'), backgroundColor: const Color(0xFF0A0E17)),
      body: const Center(child: Text('Linked Accounts Page', style: TextStyle(color: Colors.white))),
    );
  }
}