import 'package:flutter/material.dart';

class AddressFrame extends StatelessWidget {
  final String fullAddress;

  const AddressFrame({
    super.key,
    required this.fullAddress,
  });

  // Small utility function to truncate addresses (e.g., 0x7a89...4b2f) safely
  String get truncatedAddress {
    if (fullAddress.length <= 10) return fullAddress;
    return '${fullAddress.substring(0, 6)}...${fullAddress.substring(fullAddress.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.purpleAccent, size: 18),
          const SizedBox(width: 10),
          Text(
            truncatedAddress,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.grey, size: 16),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            onPressed: () {
              // Copy functionality will link here later
            },
          ),
        ],
      ),
    );
  }
}