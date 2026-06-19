// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class PortfolioCard extends StatelessWidget {
  final double fiatBalance;
  final String fiatAccountNumber;
  final double cryptoBalance;
  final String cryptoSymbol;
  final double cryptoFiatValue;
  final String cryptoAddress;
  final VoidCallback onFiatTap;
  final VoidCallback onCryptoTap;
  final bool isBalanceHidden;

  const PortfolioCard({
    super.key,
    required this.fiatBalance,
    required this.fiatAccountNumber,
    required this.cryptoBalance,
    required this.cryptoSymbol,
    required this.cryptoFiatValue,
    required this.cryptoAddress,
    required this.onFiatTap,
    required this.onCryptoTap,
    this.isBalanceHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🚀 FIXED: The redundant text and total balance widgets have been completely removed!

        // ATM CARD LAYOUT LIST (Horizontal Scroll for high-end look)
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // FIAT DEBIT CARD
              GestureDetector(
                onTap: onFiatTap,
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.15), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'FIAT WALLET', 
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Icon(Icons.contactless, color: Colors.white.withValues(alpha: 0.6), size: 22),
                        ],
                      ),
                      Text(
                        isBalanceHidden ? '••••••' : '\$${fiatBalance.toStringAsFixed(2)}', 
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '**** **** **** $fiatAccountNumber', 
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
                          ),
                          const Text(
                            'VISA', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // WEB3 CRYPTO CARD
              GestureDetector(
                onTap: onCryptoTap,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C1D95), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.15), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'WEB3 SMART WALLET', 
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Icon(Icons.layers, color: Colors.white.withValues(alpha: 0.6), size: 22),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBalanceHidden ? '••••••' : '$cryptoBalance $cryptoSymbol', 
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                          Text(
                            isBalanceHidden ? '••••••' : '\$${cryptoFiatValue.toStringAsFixed(2)} USD', 
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cryptoAddress, 
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                          ),
                          Icon(Icons.token, color: Colors.white.withValues(alpha: 0.8), size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}