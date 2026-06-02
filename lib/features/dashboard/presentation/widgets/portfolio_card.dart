import 'package:flutter/material.dart';

class PortfolioCard extends StatelessWidget {
  final double fiatBalance;
  final String fiatAccountNumber;
  final double cryptoBalance;
  final String cryptoSymbol;
  final double cryptoFiatValue;
  final String cryptoAddress;

  const PortfolioCard({
    super.key,
    required this.fiatBalance,
    required this.fiatAccountNumber,
    required this.cryptoBalance,
    required this.cryptoSymbol,
    required this.cryptoFiatValue,
    required this.cryptoAddress,
  });

  @override
  Widget build(BuildContext context) {
    // Custom premium emerald color definitions
    const Color emeraldColor = Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------------------
        // NET WORTH HEADER SECTION
        // ------------------------------------------------------------------
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
          crossAxisAlignment: CrossAxisAlignment.center, // FIXED property name
          children: [
            Text(
              '\$${(fiatBalance + cryptoFiatValue).toStringAsFixed(2)}',
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
                    style: TextStyle(
                      color: emeraldColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ------------------------------------------------------------------
        // SIDE-BY-SIDE WALLET GRID LAYOUT
        // ------------------------------------------------------------------
        Row(
          children: [
            // Left Card Block: Fiat Engine Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[950],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance, color: Colors.blueAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'FIAT WALLET',
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '\$${fiatBalance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Account: **** $fiatAccountNumber',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Card Block: Web3 Wallet Engine Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[950],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.purpleAccent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.language, color: Colors.purpleAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'WEB3 WALLET',
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$cryptoBalance $cryptoSymbol',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Address: $cryptoAddress',
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}