import 'package:flutter/material.dart';
import '../../data/models/bank_card_model.dart';
import '../widgets/portfolio_card.dart';
import 'extended_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    const Color emeraldColor = Color(0xFF10B981);
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
        // 2. Profile icon under Pay Fintech title path
        leading: GestureDetector(
          onTap: () => _navigateTo(context, const UserProfileScreen()),
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1A1A1A),
              child: Icon(Icons.person, color: Colors.grey, size: 18),
            ),
          ),
        ),
        title: const Text('Pay Fintech', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          // 3. Notification Hub Path
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _navigateTo(context, const NotificationsScreen()),
          ),
          // 4. Replaced Settings with Help Icon -> Customer Care
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _navigateTo(context, const CustomerCareScreen()),
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
              
              // 5. Beautiful ATM Cards with explicit view handlers
              PortfolioCard(
                fiatBalance: userAccount.balance,
                fiatAccountNumber: userAccount.lastFourDigits,
                cryptoBalance: 0.844,
                cryptoSymbol: 'ETH',
                cryptoFiatValue: 2120.80,
                cryptoAddress: '0x7a...4e9f',
                onFiatTap: () => _navigateTo(context, const ActionPlaceholderScreen(title: 'Fiat Details')),
                onCryptoTap: () => _navigateTo(context, const ActionPlaceholderScreen(title: 'Web3 Details')),
              ),
              
              const SizedBox(height: 24),

              // 6 & 7. Professional Functional Utility Action Hub
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(context, Icons.call_made, 'Send', Colors.blueAccent, const ActionPlaceholderScreen(title: 'Send Money')),
                  _buildActionButton(context, Icons.call_received, 'Receive', emeraldColor, const ActionPlaceholderScreen(title: 'Receive Assets')),
                  _buildActionButton(context, Icons.swap_horiz, 'Swap', Colors.purpleAccent, const ActionPlaceholderScreen(title: 'Instant Swap DEX')),
                  _buildActionButton(context, Icons.account_balance_wallet, 'CashOut', Colors.orangeAccent, const ActionPlaceholderScreen(title: 'Fiat CashOut Off-Ramp')),
                ],
              ),

              const SizedBox(height: 24),
              const Text('RECENT ACTIVITY', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLedgerRow(Icons.movie_filter, Colors.blueAccent, 'Netflix Subscription', 'Debit Card • 2 mins ago', '-\$14.99', false),
                    _buildLedgerRow(Icons.token, Colors.purpleAccent, 'Minted NFT #4412', 'Status: Confirmed • 15 mins ago', '-0.002 ETH', true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color accentColor, Widget targetScreen) {
    return GestureDetector(
      onTap: () => _navigateTo(context, targetScreen),
      child: Column(
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
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(IconData icon, Color iconColor, String title, String subtitle, String amount, bool isCrypto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[950], borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}