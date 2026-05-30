import 'package:flutter/material.dart';

class CryptoAssetTile extends StatelessWidget {
  final String tokenName;
  final String tokenSymbol;
  final double cryptoBalance;
  final double fiatValue;
  final IconData tokenIcon;

  const CryptoAssetTile({
    super.key,
    required this.tokenName,
    required this.tokenSymbol,
    required this.cryptoBalance,
    required this.fiatValue,
    required this.tokenIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Dynamic Token Rounded Avatar Frame
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(tokenIcon, color: Colors.purpleAccent, size: 24),
          ),
          const SizedBox(width: 16),
          
          // Token Label Names Layout Metadata block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tokenName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tokenSymbol,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          
          // Balance and Market Pricing Conversion Calculations Block 
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cryptoBalance.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${fiatValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}