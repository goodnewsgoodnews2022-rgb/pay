// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FAQModel {
  final String question;
  final String answer;
  final IconData categoryIcon;

  FAQModel({
    required this.question,
    required this.answer,
    required this.categoryIcon,
  });
}

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    // List containing your specific required Fintech FAQ questions and data models
    final List<FAQModel> faqList = [
      FAQModel(
        question: 'How do I send money?',
        categoryIcon: Icons.send_rounded,
        answer: 'To send money, navigate to the main dashboard and click on "Transfer". Choose whether you want to send money via Bank Transfer, Card Ledger peer-to-peer, or global routing networks. Enter the recipient details, verify the amount, authorize with your secure PIN, and your transaction will process immediately.',
      ),
      FAQModel(
        question: 'How do I withdraw funds?',
        categoryIcon: Icons.account_balance_wallet_rounded,
        answer: 'You can withdraw funds by clicking on "Withdraw" from your wallet layout screen. Select your linked settlement account, input the amount you want to pull out, and confirm the authorization prompt. Standard withdrawals clear within 5 to 30 minutes depending on your clearing bank network.',
      ),
      FAQModel(
        question: 'How do I reset my password?',
        categoryIcon: Icons.lock_reset_rounded,
        answer: 'If you are logged out, click "Forgot Password" on the sign-in viewport screen. If you are already logged in, navigate to More Screen -> Security Settings -> Change Password. A temporary secure validation code will be routed directly to your authentication email or active mobile number.',
      ),
      FAQModel(
        question: 'What are the transaction fees?',
        categoryIcon: Icons.percent_rounded,
        answer: 'Account creation, receiving transfers, and peer-to-peer domestic payments are completely free. Standard outward bank transfers carry a flat fee of 1.2% capped at maximum platform thresholds. You can inspect exact real-time network breakdown margins dynamically on the transaction review ledger sheet prior to confirming any money transfer.',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(), // Navigates seamlessly back to Support Center
        ),
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Informational Header card banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: accentPrimaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentPrimaryColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: accentPrimaryColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Can\'t find what you need? Open a Live Chat inside the Support Center for immediate agent assistance.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Build the dynamic FAQ tile accordions list layout
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final faq = faqList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Theme(
                    // Removes the default accent divider line borders added by ExpansionTile built-in assets
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(faq.categoryIcon, color: accentPrimaryColor, size: 18),
                      ),
                      title: Text(
                        faq.question,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      iconColor: accentPrimaryColor,
                      collapsedIconColor: theme.colorScheme.onSurface.withOpacity(0.4),
                      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      expandedAlignment: Alignment.centerLeft,
                      children: [
                        Text(
                          faq.answer,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}