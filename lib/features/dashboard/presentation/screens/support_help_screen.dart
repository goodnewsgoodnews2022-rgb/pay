import 'package:flutter/material.dart';

class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(title: const Text('Help & Support'), backgroundColor: const Color(0xFF0A0E17)),
      body: const Center(child: Text('Support Center Page', style: TextStyle(color: Colors.white))),
    );
  }
}