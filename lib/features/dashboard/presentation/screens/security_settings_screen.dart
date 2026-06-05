import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(title: const Text('Security Settings'), backgroundColor: const Color(0xFF0A0E17)),
      body: const Center(child: Text('Security Settings Page', style: TextStyle(color: Colors.white))),
    );
  }
}