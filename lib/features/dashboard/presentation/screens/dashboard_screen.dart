import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../data/models/bank_card_model.dart';
import '../widgets/portfolio_card.dart';
import 'extended_screens.dart';

class DashboardScreen extends StatefulWidget {
  final Function(Widget) onNavigateToSubScreen;

  const DashboardScreen({
    super.key,
    required this.onNavigateToSubScreen,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 🚀 Privacy state controller across all dashboard balance components
  bool _isBalanceHidden = false;

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final firstPart = fullName.trim().split(' ').first;
    return firstPart[0].toUpperCase() + firstPart.substring(1).toLowerCase();
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

    // Static math placeholder mapping your dynamic combined net worth
    const double staticNetWorth = 14210.80; 

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = 'User';
        if (state is AuthAuthenticated) {
          displayName = _getFirstName(state.user.fullName ?? 'User');
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => widget.onNavigateToSubScreen(const UserProfileScreen()),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF1A1A1A),
                  child: Icon(Icons.person, color: Colors.grey, size: 18),
                ),
              ),
            ),
            title: Text(
              'Hello $displayName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () => widget.onNavigateToSubScreen(const NotificationsScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => widget.onNavigateToSubScreen(const CustomerCareScreen()),
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
                  
                  // ====================================================================
                  // TOTAL NET WORTH BANNER (With Dynamic Privacy Eye Icon Toggle)
                  // ====================================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL NET WORTH',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isBalanceHidden ? '••••••' : '\$${staticNetWorth.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBalanceHidden = !_isBalanceHidden;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ====================================================================
                  // PORTFOLIO CARDS (Passing visibility configuration parameters downstream)
                  // ====================================================================
                  PortfolioCard(
                    fiatBalance: userAccount.balance,
                    fiatAccountNumber: userAccount.lastFourDigits,
                    cryptoBalance: 0.844,
                    cryptoSymbol: 'ETH',
                    cryptoFiatValue: 2120.80,
                    cryptoAddress: '0x7a...4e9f',
                    isBalanceHidden: _isBalanceHidden, // 🚀 Dynamic sync flag
                    onFiatTap: () => widget.onNavigateToSubScreen(const ActionPlaceholderScreen(title: 'Fiat Details')),
                    onCryptoTap: () => widget.onNavigateToSubScreen(const ActionPlaceholderScreen(title: 'Web3 Details')),
                  ),
                  
                  const SizedBox(height: 24),

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
      },
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color accentColor, Widget targetScreen) {
    return GestureDetector(
      onTap: () => widget.onNavigateToSubScreen(targetScreen),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[950],
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withAlpha(38), width: 1),
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