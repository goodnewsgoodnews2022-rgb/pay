// ignore_for_file: unnecessary_non_null_assertion, deprecated_member_use, unused_import

import 'package:fintech/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState; 
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../data/models/bank_card_model.dart';
import '../widgets/portfolio_card.dart';
import 'support_help_screen.dart';
import '../../../notifications/presentation/screen/notification_screen.dart';

// Placeholder classes to resolve undefined name errors
class SendScreen extends StatelessWidget { const SendScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Send Screen'))); }
class ReceiveScreen extends StatelessWidget { const ReceiveScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Receive Screen'))); }
class SwapScreen extends StatelessWidget { const SwapScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Swap Screen'))); }
class CashOutScreen extends StatelessWidget { const CashOutScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('CashOut Screen'))); }

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
  // Privacy state controller across all dashboard balance components
  bool _isBalanceHidden = false;
  
  // Stream storage reference to hold the live database link
  Stream<List<Map<String, dynamic>>>? _profileStream;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // 🛡️ CRITICAL FIX: Safe initialization sequence to capture user state at route mounting
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _initializeProfileStream();
  }

  @override
  void dispose() {
    // Kill stream mapping hooks immediately before element tree destruction
    _profileStream = null;
    super.dispose();
  }

  // Live listener connection targeting this exact user's database profile row
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
    // 🎨 THEME ADAPTATION LAYER
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDarkMode ? Colors.black : const Color(0xFFF8FAFC); 
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    
    // 🛡️ CRITICAL FIX: Removed unsafe "!" operators and provided rock-solid color fallbacks
    final secondaryTextColor = isDarkMode 
        ? (Colors.grey[400] ?? const Color(0xFF94A3B8)) 
        : const Color(0xFF475569);
        
    final componentBgColor = isDarkMode 
        ? (Colors.grey[900] ?? const Color(0xFF0F172A)) // Colors.grey only goes up to 900.
        : Colors.white;
        
    final iconWrapperBg = isDarkMode ? Colors.black : const Color(0xFFF1F5F9);
    final subSectionTitleColor = isDarkMode ? Colors.grey : const Color(0xFF64748B);

    final cardGradient = isDarkMode 
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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint('DASHBOARD AUTH STATE DETECTED: ===> $state');

        final currentUser = Supabase.instance.client.auth.currentUser;
        String fallbackName = _getFirstName(currentUser?.userMetadata?['full_name'] ?? 'User');

        if (state is AuthAuthenticated) {
          fallbackName = _getFirstName(state.user.fullName ?? 'User');
        }

        final String? fallbackAvatarUrl = currentUser?.userMetadata?['avatar_url'] ?? currentUser?.userMetadata?['profile_picture'];

        // ====================================================================
        // UNIFIED STREAM PATTERN (Fixes nested StreamBuilder loops on Web)
        // ====================================================================
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            // 🛡️ Guard framework against unmounted state emissions mid-route transition
            if (!mounted) return const SizedBox.shrink();

            String resolvedName = fallbackName;
            String? resolvedAvatarUrl = fallbackAvatarUrl;

            // Extract default/fallback stream variables for card 
            double liveFiatBalance = 0.00;
            String liveFiatAccountLabel = "NGN Wallet Balance";
            double liveCryptoBalance = 0.000;
            double liveCryptoFiatValue = 0.00;
            String liveCryptoAddress = "Not Available";

            if (snapshot.hasData && snapshot.data!.isNotEmpty && !snapshot.hasError) {
              final row = snapshot.data!.first;
              
              // 1. Resolve Identity Header Details
              resolvedAvatarUrl = row['avatar_url'] ?? row['profile_picture'] ?? resolvedAvatarUrl;
              final String? dbName = row['full_name'];
              if (dbName != null && dbName.isNotEmpty && state is! AuthAuthenticated) {
                resolvedName = _getFirstName(dbName);
              }

              // 2. Extract Real-time Supabase Core Ledger balances
              // Safely parsing numeric database objects to double values
              liveFiatBalance = (row['fiat_balance'] ?? 0.0).toDouble();
              
              // If your DB contains alternative dynamic account strings, parse it here:
              liveFiatAccountLabel = row['fiat_account_number'] ?? "NGN Wallet Balance";

              liveCryptoBalance = (row['crypto_balance'] ?? 0.000).toDouble();
              liveCryptoFiatValue = (row['crypto_fiat_value'] ?? 0.00).toDouble();
              liveCryptoAddress = row['crypto_address'] ?? "0x7a...4e9f";
            }

            // 💡 Dynamic calculation of Total Net Worth based on database fields
            final double totalNetWorth = liveFiatBalance + liveCryptoFiatValue;

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
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, color: isDarkMode ? Colors.grey : const Color(0xFF94A3B8), size: 18);
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Icon(Icons.person, color: isDarkMode ? Colors.grey : const Color(0xFF94A3B8), size: 18),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Hello $resolvedName',
                  style: TextStyle(
                    color: mainTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: mainTextColor),
                    onPressed: () => widget.onNavigateToSubScreen(const NotificationScreen()),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: mainTextColor),
                    onPressed: () => widget.onNavigateToSubScreen(const SupportHelpScreen()),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ====================================================================
                        // UNIFIED NET WORTH & WALLET HUB GRADIENT CONTAINER
                        // ====================================================================
                        Container(
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            gradient: cardGradient,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: cardBorderColor, 
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
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
                                        onPressed: () {
                                          setState(() {
                                            _isBalanceHidden = !_isBalanceHidden;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: emeraldColor.withOpacity(isDarkMode ? 0.12 : 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: emeraldColor.withOpacity(0.4), width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, color: isDarkMode ? emeraldColor : Colors.white, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Add Money',
                                            style: TextStyle(
                                              color: isDarkMode ? emeraldColor : Colors.white,
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
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _isBalanceHidden ? '••••••' : '\$${totalNetWorth.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (!_isBalanceHidden) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: emeraldColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.arrow_drop_up, color: emeraldColor, size: 14),
                                          Text(
                                            '4.2%',
                                            style: TextStyle(
                                              color: emeraldColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ====================================================================
                        // PORTFOLIO CARDS SECTION (💡 NOW DRIVEN BY SUPABASE DATA STREAMS)
                        // ====================================================================
                        PortfolioCard(
                          fiatBalance: liveFiatBalance,
                          fiatAccountNumber: liveFiatAccountLabel, 
                          cryptoBalance: liveCryptoBalance,
                          cryptoSymbol: 'ETH',
                          cryptoFiatValue: liveCryptoFiatValue,
                          cryptoAddress: liveCryptoAddress,
                          isBalanceHidden: _isBalanceHidden,
                          onFiatTap: () => widget.onNavigateToSubScreen(const SendScreen()),   
                          onCryptoTap: () => widget.onNavigateToSubScreen(const ReceiveScreen()), 
                        ),
                        const SizedBox(height: 24),
                        // ====================================================================
                        // ACTION BUTTON HUB (FULLY WIRED TO ROUTE HANDLERS)
                        // ====================================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionButton(context, Icons.call_made, 'Send', Colors.blueAccent, const SendScreen(), componentBgColor, mainTextColor, isDarkMode),
                            _buildActionButton(context, Icons.call_received, 'Receive', emeraldColor, const ReceiveScreen(), componentBgColor, mainTextColor, isDarkMode),
                            _buildActionButton(context, Icons.swap_horiz, 'Swap', Colors.purpleAccent, const SwapScreen(), componentBgColor, mainTextColor, isDarkMode),
                            _buildActionButton(context, Icons.account_balance_wallet, 'CashOut', Colors.orangeAccent, const CashOutScreen(), componentBgColor, mainTextColor, isDarkMode),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('RECENT ACTIVITY', style: TextStyle(color: subSectionTitleColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        _buildLedgerRow(Icons.movie_filter, Colors.blueAccent, 'Netflix Subscription', 'Debit Card • 2 mins ago', _isBalanceHidden ? '••••' : '-\$14.99', componentBgColor, mainTextColor, secondaryTextColor, iconWrapperBg),
                        _buildLedgerRow(Icons.token, Colors.purpleAccent, 'Minted NFT #4412', 'Status: Confirmed • 15 mins ago', _isBalanceHidden ? '••••' : '-0.002 ETH', componentBgColor, mainTextColor, secondaryTextColor, iconWrapperBg),
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

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color accentColor, Widget? targetScreen, Color componentBgColor, Color mainTextColor, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (!mounted || targetScreen == null) return;
        widget.onNavigateToSubScreen(targetScreen);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: componentBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: isDarkMode ? accentColor.withOpacity(0.15) : const Color(0xFFE2E8F0), width: 1),
              boxShadow: isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: componentBgColor, 
        borderRadius: BorderRadius.circular(14),
        border: componentBgColor == Colors.white ? Border.all(color: const Color(0xFFE2E8F0), width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconWrapperBg, borderRadius: BorderRadius.circular(10)),
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
          Text(amount, style: TextStyle(color: mainTextColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}