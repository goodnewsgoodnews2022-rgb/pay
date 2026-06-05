import 'package:flutter/material.dart';

class Web3SettingsScreen extends StatelessWidget {
  const Web3SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(title: const Text('Web3 Wallet Ecosystem'), backgroundColor: const Color(0xFF0A0E17)),
      body: const Center(child: Text('Web3 Settings Page', style: TextStyle(color: Colors.white))),
    );
  }
}