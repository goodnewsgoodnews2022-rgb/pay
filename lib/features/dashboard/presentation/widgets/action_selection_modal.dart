// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ActionSelectionModal extends StatelessWidget {
  final String title;
  final VoidCallback onFiatSelected;
  final VoidCallback onCryptoSelected;

  const ActionSelectionModal({
    super.key,
    required this.title,
    required this.onFiatSelected,
    required this.onCryptoSelected,
  });

  static void show({
    required BuildContext context,
    required String title,
    required VoidCallback onFiatSelected,
    required VoidCallback onCryptoSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionSelectionModal(
        title: title,
        onFiatSelected: onFiatSelected,
        onCryptoSelected: onCryptoSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF121214), // Matches the dark theme of your dashboard layout
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // FIAT OPTION BUTTON
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onFiatSelected();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.blueAccent, size: 28),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FIAT WALLET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('Bank account, cards, and local transfers', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // CRYPTO OPTION BUTTON
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onCryptoSelected();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.currency_bitcoin, color: Colors.purpleAccent, size: 28),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WEB3 SMART WALLET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('Secure TRC20 and BEP20 blockchain networks', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}