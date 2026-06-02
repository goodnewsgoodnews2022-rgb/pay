import 'package:flutter/material.dart';
import '../../data/models/bank_card_model.dart';
import '../widgets/portfolio_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom premium emerald color mapping
    const Color emeraldColor = Color(0xFF10B981);

    // Model Instance matching your exact specifications
    const BankCardModel userAccount = BankCardModel(
      id: 'fiat-8921',
      cardHolderName: 'LAWRENCE',
      lastFourDigits: '8921',
      cardExpiry: '08/30',
      balance: 12450.00,
      cardType: 'Visa',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFF1A1A1A),
            child: Icon(Icons.person, color: Colors.grey, size: 18),
          ),
        ),
        title: const Text(
          'Pay Fintech',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Dynamic Multi-Currency Balance Component Frame
              PortfolioCard(
                fiatBalance: userAccount.balance,
                fiatAccountNumber: userAccount.lastFourDigits,
                cryptoBalance: 0.844,
                cryptoSymbol: 'ETH',
                cryptoFiatValue: 2120.80,
                cryptoAddress: '0x7a...4e9f',
              ),
              
              const SizedBox(height: 24),

              // ------------------------------------------------------------------
              // QUICK ACTION BUTTONS HUB
              // ------------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(Icons.call_made, 'Send', Colors.blueAccent),
                  _buildActionButton(Icons.call_received, 'Receive', emeraldColor), // FIXED color parameter
                  _buildActionButton(Icons.swap_horiz, 'Swap', Colors.purpleAccent),
                  _buildActionButton(Icons.account_balance_wallet, 'CashOut', Colors.orangeAccent),
                ],
              ),

              const SizedBox(height: 32),

              // SECTION HEADER LABEL BLOCK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT ACTIVITY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ------------------------------------------------------------------
              // UNIFIED MULTI-ENGINE ACTIVITY LEDGER STREAM
              // ------------------------------------------------------------------
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLedgerRow(
                      icon: Icons.movie_filter,
                      iconColor: Colors.blueAccent,
                      title: 'Netflix Subscription',
                      subtitle: 'Debit Card • 2 mins ago',
                      amount: '-\$14.99',
                      isCrypto: false,
                    ),
                    _buildLedgerRow(
                      icon: Icons.token,
                      iconColor: Colors.purpleAccent,
                      title: 'Minted NFT #4412 (Gas: \$4.20)',
                      subtitle: 'Status: Confirmed • 15 mins ago',
                      amount: '-0.002 ETH',
                      isCrypto: true,
                    ),
                    _buildLedgerRow(
                      icon: Icons.work_outline,
                      iconColor: Colors.blueAccent,
                      title: 'Received Salary (Tech Corp)',
                      subtitle: 'Direct Deposit • 2 hours ago',
                      amount: '+\$4,500.00',
                      isCrypto: false,
                      isPositive: true,
                      positiveColor: emeraldColor, // Passed fixed custom color
                    ),
                    _buildLedgerRow(
                      icon: Icons.currency_exchange,
                      iconColor: Colors.purpleAccent,
                      title: 'Swapped USDC to ETH',
                      subtitle: 'Tx: Successfully Executed • 1 day ago',
                      amount: '+0.25 ETH',
                      isCrypto: true,
                      isPositive: true,
                      positiveColor: emeraldColor, // Passed fixed custom color
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Action Component Generator Helper
  Widget _buildActionButton(IconData icon, String label, Color accentColor) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[950],
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Unified Multi-Engine Ledger Row Component Builder
  Widget _buildLedgerRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isCrypto,
    bool isPositive = false,
    Color positiveColor = Colors.green,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[950],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              color: isPositive ? positiveColor : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}