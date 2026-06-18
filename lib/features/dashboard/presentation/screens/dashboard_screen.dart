// ignore_for_file: deprecated_member_use, unnecessary_non_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// State Management & Models
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../../fiat_wallet/domain/entities/fiat_wallet_model.dart';
import '../widgets/portfolio_card.dart';

// Navigation Targets
import 'package:fintech/features/profile/presentation/screens/profile_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/support_help_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/add_money_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_swap_screen.dart';
import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_withdrawal_screen.dart';
import '../../../notifications/presentation/screen/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(Widget) onNavigateToSubScreen;

  const DashboardScreen({super.key, required this.onNavigateToSubScreen});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceHidden = false;
  
  Stream<List<Map<String, dynamic>>>? _profileStream;
  Stream<List<Map<String, dynamic>>>? _walletStream;
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    if (_currentUserId == null) return;

    _profileStream = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', _currentUserId!);

    _walletStream = Supabase.instance.client
        .from('fiat_wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', _currentUserId!);
  }

  String _formatFirstName(String fullName) {
    if (fullName.trim().isEmpty) return 'User';
    final firstPart = fullName.trim().split(' ').first;
    return firstPart.isEmpty 
        ? 'User' 
        : '${firstPart[0].toUpperCase()}${firstPart.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, profileSnapshot) {
            
            String displayName = 'User';
            String? avatarUrl;

            if (authState is AuthAuthenticated) {
              displayName = _formatFirstName(authState.user.fullName ?? 'User');
            } else {
              final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
              displayName = _formatFirstName(metadata?['full_name'] ?? 'User');
              avatarUrl = metadata?['avatar_url'] ?? metadata?['profile_picture'];
            }

            if (profileSnapshot.hasData && profileSnapshot.data!.isNotEmpty) {
              final row = profileSnapshot.data!.first;
              avatarUrl = row['avatar_url'] ?? row['profile_picture'] ?? avatarUrl;
              final String? dbName = row['full_name'];
              if (dbName != null && dbName.isNotEmpty && authState is! AuthAuthenticated) {
                displayName = _formatFirstName(dbName);
              }
            }

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: _buildAppBar(theme, isDark, displayName, avatarUrl),
              body: SafeArea(
                // 🛡️ LAYOUT GUARD: Explicitly enforces device screen width/height limits
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _walletStream,
                      builder: (context, walletSnapshot) {
                        if (walletSnapshot.hasError) {
                          return const Center(child: Text('Error loading account metrics.'));
                        }

                        FiatWalletModel dynamicWallet = const FiatWalletModel(
                          ngnBalance: 0.0,
                          usdBalance: 0.0,
                          eurBalance: 0.0,
                        );

                        if (walletSnapshot.hasData && walletSnapshot.data!.isNotEmpty) {
                          dynamicWallet = FiatWalletModel.fromMap(walletSnapshot.data!.first);
                        }

                        final double aggregatedNetWorth = dynamicWallet.calculateTotalInUSD();

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNetWorthCard(theme, isDark, aggregatedNetWorth),
                              const SizedBox(height: 16),
                              _buildSmartWalletCard(dynamicWallet),
                              const SizedBox(height: 24),
                              _buildQuickActionsMatrix(context),
                              const SizedBox(height: 24),
                              _buildRecentActivitySection(theme, isDark),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark, String name, String? avatarUrl) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.colorScheme.onSurface),
      leading: GestureDetector(
        onTap: () => widget.onNavigateToSubScreen(const ProfileScreen()),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 18),
                    )
                  : const Icon(Icons.person, size: 18),
            ),
          ),
        ),
      ),
      title: Text(
        'Hello $name',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () => widget.onNavigateToSubScreen(const NotificationScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => widget.onNavigateToSubScreen(const SupportHelpScreen()),
        ),
      ],
    );
  }

  Widget _buildNetWorthCard(ThemeData theme, bool isDark, double totalNetWorth) {
    const Color emeraldColor = Color(0xFF10B981);
    
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF151424), const Color(0xFF0A0A0C)]
              : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF26243C) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TOTAL NET WORTH (USD)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => widget.onNavigateToSubScreen(const AddMoneyScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: emeraldColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: emeraldColor.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: emeraldColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add Money',
                        style: TextStyle(
                          color: emeraldColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isBalanceHidden ? '••••••' : '\$${totalNetWorth.toStringAsFixed(2)}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🚀 FIXED: Wrapped PortfolioCard inside a bounded layout constraint context to avoid screen overflows
  Widget _buildSmartWalletCard(FiatWalletModel wallet) {
    final bool hasUsd = wallet.usdBalance > 0;
    return SizedBox(
      width: double.infinity,
      child: PortfolioCard(
        fiatBalance: hasUsd ? wallet.usdBalance : wallet.ngnBalance,
        fiatAccountNumber: hasUsd ? "USD Stable Ledger" : "NGN Wallet Balance",
        cryptoBalance: 0.00,
        cryptoSymbol: 'USDT',
        cryptoFiatValue: hasUsd ? wallet.usdBalance : wallet.ngnBalance,
        cryptoAddress: '0xWeb3...Wallet',
        isBalanceHidden: _isBalanceHidden,
        onFiatTap: () {},
        onCryptoTap: () {},
      ),
    );
  }

  Widget _buildQuickActionsMatrix(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(context, Icons.call_made, 'Send', Colors.blueAccent, const AddMoneyScreen()),
        _buildActionButton(context, Icons.call_received, 'Receive', const Color(0xFF10B981), const AddMoneyScreen()),
        _buildActionButton(context, Icons.swap_horiz, 'Swap', Colors.purpleAccent, const CryptoSwapScreen()),
        _buildActionButton(context, Icons.account_balance_wallet, 'Withdraw', Colors.orangeAccent, const CryptoWithdrawalScreen()),
      ],
    );
  }

  Widget _buildRecentActivitySection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            color: isDark ? Colors.grey : Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildLedgerRow(context, Icons.movie_filter, Colors.blueAccent, 'Netflix Subscription', 'Debit Card • 2 mins ago', '-\$14.99'),
        _buildLedgerRow(context, Icons.token, Colors.purpleAccent, 'Minted NFT #4412', 'Status: Confirmed • 15 mins ago', '-0.002 ETH'),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color accentColor, Widget targetScreen) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onNavigateToSubScreen(targetScreen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0E0E11) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerRow(BuildContext context, IconData icon, Color iconColor, String title, String subtitle, String amount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E0E11) : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: isDark ? null : Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: isDark ? null : Border.all(color: Colors.grey[100]!),
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
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
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