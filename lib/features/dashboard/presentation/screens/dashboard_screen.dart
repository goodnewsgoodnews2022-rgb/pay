// ignore_for_file: prefer_const_constructors, duplicate_import, unnecessary_non_null_assertion, deprecated_member_use, unused_import

import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_withdrawal_screen.dart';
import 'package:fintech/features/support/presentation/screens/Chat_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState; 

import 'package:fintech/features/crypto_wallet/presentation/screens/crypto_swap_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/add_money_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/receive_funds_screen.dart';
import 'package:fintech/features/dashboard/presentation/screens/send_funds_screen.dart';
import 'package:fintech/features/fiat_wallet/presentation/screens/withdraw_screen.dart';
import 'package:fintech/features/profile/presentation/screens/profile_screen.dart';
import 'package:fintech/features/fiat_wallet/presentation/screens/deposit_screen.dart';
import 'package:fintech/features/dashboard/providers/wallet_provider.dart'; 

import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../data/models/bank_card_model.dart';
import 'support_help_screen.dart';
import '../../../notifications/presentation/screen/notification_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(Widget) onNavigateToSubScreen;

  const DashboardScreen({
    super.key,
    required this.onNavigateToSubScreen,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isBalanceHidden = false;
  Stream<List<Map<String, dynamic>>>? _profileStream;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _initializeProfileStream();
  }

  @override
  void dispose() {
    _profileStream = null;
    super.dispose();
  }

  void _initializeProfileStream() {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      _profileStream = Supabase.instance.client
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', _currentUserId!);
    }
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final firstPart = fullName.trim().split(' ').first;
    if (firstPart.isEmpty) return 'User';
    return firstPart[0].toUpperCase() + firstPart.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDarkMode ? const Color(0xFF090A0F) : const Color(0xFFF8FAFC); 
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    
    final secondaryTextColor = isDarkMode 
        ? (Colors.grey[400] ?? const Color(0xFF94A3B8)) 
        : const Color(0xFF475569);
        
    final componentBgColor = isDarkMode ? const Color(0xFF131520) : Colors.white;
    final iconWrapperBg = isDarkMode ? const Color(0xFF1E2235) : const Color(0xFFF1F5F9);
    final subSectionTitleColor = isDarkMode ? Colors.grey[500] : const Color(0xFF64748B);

    final netWorthGradient = isDarkMode 
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF151424), Color(0xFF0A0A0C)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF311042)], 
          );

    final cardBorderColor = isDarkMode ? const Color(0xFF26243C) : const Color(0xFF4338CA).withOpacity(0.2);
    const Color emeraldColor = Color(0xFF10B981);

    // Watch the live global Realtime Supabase wallet provider via Riverpod
    final walletAsyncValue = ref.watch(fiatWalletStreamProvider);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        String fallbackName = _getFirstName(currentUser?.userMetadata?['full_name'] ?? 'User');

        if (state is AuthAuthenticated) {
          fallbackName = _getFirstName(state.user.fullName ?? 'User');
        }

        final String? fallbackAvatarUrl = currentUser?.userMetadata?['avatar_url'] ?? currentUser?.userMetadata?['profile_picture'];

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            if (!mounted) return const SizedBox.shrink();

            String resolvedName = fallbackName;
            String? resolvedAvatarUrl = fallbackAvatarUrl;

            double profileNairaBalanceFallback = 0.00; 
            double liveCryptoBalance = 0.00; 
            double liveCryptoFiatValue = 0.00; 
            String liveCryptoAddress = "0xWeb3...Wallet";

            if (snapshot.hasData && snapshot.data!.isNotEmpty && !snapshot.hasError) {
              final row = snapshot.data!.first;
              
              resolvedAvatarUrl = row['avatar_url'] ?? row['profile_picture'] ?? resolvedAvatarUrl;
              final String? dbName = row['full_name'];
              if (dbName != null && dbName.isNotEmpty && state is! AuthAuthenticated) {
                resolvedName = _getFirstName(dbName);
              }

              profileNairaBalanceFallback = (row['naira_balance'] ?? 0.0).toDouble(); 
              liveCryptoBalance = (row['crypto_balance'] ?? 0.0).toDouble(); 
              liveCryptoFiatValue = (row['crypto_fiat_value'] ?? 0.0).toDouble(); 
              liveCryptoAddress = row['crypto_address'] ?? "0xWeb3...Wallet";
            }

            // 💸 SAFE RIVERPOD STREAM VALUE EXTRACTION PARSER ENGINE
            final double actualLiveNaira = walletAsyncValue.when(
              data: (walletMap) => (walletMap?['ngn_balance'] ?? profileNairaBalanceFallback).toDouble(),
              loading: () => profileNairaBalanceFallback,
              error: (_, __) => profileNairaBalanceFallback,
            );

            // Compute dynamic net worth aggregation formulas instantly using exchange rate matrix
            double convertedNairaToUSD = actualLiveNaira / 1500.0;
            final double totalNetWorth = convertedNairaToUSD + liveCryptoFiatValue;

            return Scaffold(
              backgroundColor: scaffoldBg,
              appBar: AppBar(
                backgroundColor: scaffoldBg,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: GestureDetector(
                  onTap: () => widget.onNavigateToSubScreen(const ProfileScreen()),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE2E8F0),
                      child: ClipOval(
                        child: resolvedAvatarUrl != null && resolvedAvatarUrl.isNotEmpty
                            ? Image.network(
                                resolvedAvatarUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: isDarkMode ? Colors.grey : const Color(0xFF94A3B8), size: 18),
                              )
                            : Icon(Icons.person, color: isDarkMode ? Colors.grey : const Color(0xFF94A3B8), size: 18),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Hello $resolvedName',
                  style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: mainTextColor),
                    onPressed: () => widget.onNavigateToSubScreen(const NotificationScreen()),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: mainTextColor),
                    onPressed: () => widget.onNavigateToSubScreen(const ChatScreen()),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOTAL NET WORTH PANEL
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              gradient: netWorthGradient,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: cardBorderColor, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'TOTAL NET WORTH (USD)',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey[400] : Colors.white.withOpacity(0.7),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            color: isDarkMode ? Colors.grey[500] : Colors.white.withOpacity(0.6),
                                            size: 18,
                                          ),
                                          onPressed: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => widget.onNavigateToSubScreen(const AddMoneyScreen()),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: emeraldColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: emeraldColor.withOpacity(0.4)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.add, color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text('Add Money', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      _isBalanceHidden ? '••••••' : '\$${totalNetWorth.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: emeraldColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                      child: const Text('4.2%', style: TextStyle(color: emeraldColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // ====================================================================
                        // SIDE-BY-SIDE CARDS
                        // ====================================================================
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              // CARD 1: FIAT WALLET (Deep Blue Gradient)
                              _buildDashboardCard(
                                width: 310,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                ),
                                title: "FIAT WALLET",
                                balance: _isBalanceHidden ? '••••••' : '\$${convertedNairaToUSD.toStringAsFixed(2)}',
                                subBalance: null, 
                                footerText: "USD wallet",
                                footerTrailing: "VISA",
                              ),
                              const SizedBox(width: 14),
                              
                              // CARD 2: WEB3 SMART WALLET (Vibrant Deep Purple Gradient)
                              _buildDashboardCard(
                                width: 310,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                                ),
                                title: "WEB3 SMART WALLET",
                                balance: _isBalanceHidden ? '••••••' : '${liveCryptoBalance.toStringAsFixed(2)} USDT',
                                subBalance: _isBalanceHidden ? '••••••' : '\$${liveCryptoFiatValue.toStringAsFixed(2)} USD',
                                footerText: liveCryptoAddress,
                                footerTrailing: "WEB3",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // ACTION BUTTON ENGINE HUB
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildActionButton(context, Icons.call_made, 'Send', Colors.blueAccent, const SendFundsScreen(), mainTextColor),
                              _buildActionButton(context, Icons.call_received, 'Receive', emeraldColor, const ReceiveFundsScreen(), mainTextColor),
                              _buildActionButton(context, Icons.swap_horiz, 'Swap', Colors.purpleAccent, const CryptoSwapScreen(), mainTextColor),
                              _buildActionButton(context, Icons.account_balance_wallet, 'Withdraw', Colors.orangeAccent, const CryptoWithdrawalScreen(), mainTextColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // RECENT ACTIVITY LEDGER
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RECENT ACTIVITY', style: TextStyle(color: subSectionTitleColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              _buildLedgerRow(Icons.movie_filter, Colors.blueAccent, 'Netflix Subscription', 'Debit Card • 2 mins ago', _isBalanceHidden ? '••••' : '-\$14.99', componentBgColor, mainTextColor, secondaryTextColor, iconWrapperBg),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardCard({
    required double width,
    required Gradient gradient,
    required String title,
    required String balance,
    String? subBalance,
    required String footerText,
    required String footerTrailing,
  }) {
    return Container(
      width: width,
      height: 175,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(Icons.contactless, color: Colors.white.withOpacity(0.6), size: 18),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                balance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subBalance != null) ...[
                const SizedBox(height: 2),
                Text(
                  subBalance,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  footerText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                footerTrailing,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color accentColor, Widget targetScreen, Color mainTextColor) {
    return GestureDetector(
      onTap: () => widget.onNavigateToSubScreen(targetScreen),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: mainTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(IconData icon, Color iconColor, String title, String subtitle, String amount, Color componentBgColor, Color mainTextColor, Color secondaryTextColor, Color iconWrapperBg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: componentBgColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconWrapperBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: mainTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: mainTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}