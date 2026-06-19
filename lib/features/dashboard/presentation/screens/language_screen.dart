// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Default selected language code (e.g., 'en' for English)
  String _selectedLanguageCode = 'en';

  // List of the most popular languages in the world
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'nativeName': 'English', 'code': 'en'},
    {'name': 'Mandarin Chinese', 'nativeName': '中文 (Zhōngwén)', 'code': 'zh'},
    {'name': 'Spanish', 'nativeName': 'Español', 'code': 'es'},
    {'name': 'Hindi', 'nativeName': 'हिन्दी', 'code': 'hi'},
    {'name': 'Arabic', 'nativeName': 'العربية', 'code': 'ar'},
    {'name': 'French', 'nativeName': 'Français', 'code': 'fr'},
    {'name': 'Bengali', 'nativeName': 'বাংলা', 'code': 'bn'},
    {'name': 'Portuguese', 'nativeName': 'Português', 'code': 'pt'},
    {'name': 'Russian', 'nativeName': 'Русский', 'code': 'ru'},
    {'name': 'Urdu', 'nativeName': 'اُردُو', 'code': 'ur'},
    {'name': 'Indonesian', 'nativeName': 'Bahasa Indonesia', 'code': 'id'},
    {'name': 'German', 'nativeName': 'Deutsch', 'code': 'de'},
  ];

  void _handleLanguageChange(String languageCode, String languageName) {
    setState(() {
      _selectedLanguageCode = languageCode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('App language changed to $languageName'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 DYNAMIC THEME ENGINE: Checks if light mode or dark mode is running
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Resolve structural theme tokens relative to adaptive brightness rules
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDarkMode ? Colors.white38 : const Color(0xFF64748B);
    final unselectedRadioColor = isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1);
    final listDividerColor = isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor, 
      appBar: AppBar(
        title: Text(
          'Select Language', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: mainTextColor, // Dynamic app bar text
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: mainTextColor), // Dynamic back arrow
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: _languages.length,
        separatorBuilder: (context, index) => Divider(color: listDividerColor, height: 1),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguageCode == lang['code'];

          return ListTile(
            onTap: () => _handleLanguageChange(lang['code']!, lang['name']!),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            title: Text(
              lang['name']!,
              style: TextStyle(
                color: isSelected ? const Color(0xFF10B981) : mainTextColor, // Professional green accent matched with adaptive main text
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              lang['nativeName']!,
              style: TextStyle(
                color: isSelected ? const Color(0xFF10B981).withOpacity(0.7) : secondaryTextColor, // Dynamic descriptive labels
                fontSize: 13,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22)
                : Icon(Icons.radio_button_unchecked_rounded, color: unselectedRadioColor, size: 22),
          );
        },
      ),
    );
  }
}