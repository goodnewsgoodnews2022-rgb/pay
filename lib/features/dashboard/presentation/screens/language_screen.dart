// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 DYNAMIC THEME ENGINE: Checks if light mode or dark mode is running
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Resolve structural theme tokens relative to adaptive brightness rules
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDarkMode ? Colors.white38 : const Color(0xFF64748B);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(
          'App Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: mainTextColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: mainTextColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Informational fintech style notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.language_rounded, color: accentColor, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'This application currently operates exclusively in English for optimal localization and security standardization.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Single English Selection Card
          Card(
            color: isDarkMode ? const Color(0xFF111622) : Colors.grey[100],
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: const Text(
                'English',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'English (Default & Active)',
                style: TextStyle(
                  color: accentColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              trailing: const Icon(
                Icons.check_circle_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}