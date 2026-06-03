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
  // 🚀 Added configuration flag to catch privacy updates from dashboard state loops
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
    this.isBalanceHidden = false, // Defaults to visible for clean backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    const Color emeraldColor = Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TOTAL NET WORTH (USD)',
          style: TextStyle(
            color: Colors.grey, 
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Synchronized with privacy mask toggling rules
            Text(
              isBalanceHidden 
                  ? '••••••' 
                  : '\$${(fiatBalance + cryptoFiatValue).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: emeraldColor.withValues(alpha: 0.15), 
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_drop_up, color: emeraldColor, size: 16),
                  Text(
                    '4.2%', 
                    style: TextStyle(color: emeraldColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

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
                      // Conditional Privacy Mask implementation
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
                          // Token Balance Mask Rule
                          Text(
                            isBalanceHidden ? '••••••' : '$cryptoBalance $cryptoSymbol', 
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                          // Sub-Value Fiat Calculation Mask Rule
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