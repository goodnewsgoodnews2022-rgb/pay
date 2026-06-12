// ignore_for_file: undefined_hidden_name, unused_import, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:fintech/features/dashboard/presentation/screens/support_help_screen.dart';
import 'package:fintech/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState; 

import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../data/models/bank_card_model.dart';
import '../widgets/portfolio_card.dart';
import 'extended_screens.dart' hide NotificationScreen; 
import '../../../notifications/presentation/screen/notification_screen.dart';

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
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _initializeProfileStream();
  }

  // Live listener connection targeting this exact user's database profile row
  void _initializeProfileStream() {
    if (_currentUserId != null) {
      _profileStream = Supabase.instance.client
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', _currentUserId as Object);
    }
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final firstPart = fullName.trim().split(' ').first;
    return firstPart[0].toUpperCase() + firstPart.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const Color emeraldColor = Color(0xFF10B981);
    const BankCardModel userAccount = BankCardModel(
      id: 'fiat-8921',
      cardHolderName: 'LAWRENCE',
      lastFourDigits: '8921',
      cardExpiry: '08/30',
      balance: 12450.00,
      cardType: 'Visa',
    );

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint('DASHBOARD AUTH STATE DETECTED: ===> $state');

        // Fallback user defaults if stream hasn't populated yet
        final currentUser = Supabase.instance.client.auth.currentUser;
        String displayName = _getFirstName(currentUser?.userMetadata?['full_name'] ?? 'User');

        if (state is AuthAuthenticated) {
          displayName = _getFirstName(state.user.fullName ?? 'User');
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.colorScheme.onSurface),
            // ====================================================================
            // AUTOMATIC LIVE-STREAM AVATAR HEADER
            // ====================================================================
            leading: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _profileStream,
              builder: (context, snapshot) {
                String? liveAvatarUrl = currentUser?.userMetadata?['avatar_url'] ?? currentUser?.userMetadata?['profile_picture'];
                
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final row = snapshot.data!.first;
                  liveAvatarUrl = row['avatar_url'] ?? row['profile_picture'] ?? liveAvatarUrl;
                  final String? dbName = row['full_name'];
                  if (dbName != null && dbName.isNotEmpty && state is! AuthAuthenticated) {
                    displayName = _getFirstName(dbName);
                  }
                }

                return GestureDetector(
                  onTap: () => widget.onNavigateToSubScreen(const ProfileScreen()),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
                      child: ClipOval(
                        child: liveAvatarUrl != null && liveAvatarUrl.isNotEmpty
                            ? Image.network(
                                liveAvatarUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, color: isDark ? Colors.grey : Colors.grey[600], size: 18);
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
                            : Icon(Icons.person, color: isDark ? Colors.grey : Colors.grey[600], size: 18),
                      ),
                    ),
                  ),
                );
              },
            ),
            title: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _profileStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final String? liveName = snapshot.data!.first['full_name'];
                  if (liveName != null && liveName.isNotEmpty) {
                    displayName = _getFirstName(liveName);
                  }
                }
                return Text(
                  'Hello $displayName',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: theme.colorScheme.onSurface),
                onPressed: () => widget.onNavigateToSubScreen(const NotificationScreen()),
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: theme.colorScheme.onSurface),
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
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
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
                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
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
                                      color: isDark ? Colors.grey[500] : Colors.grey[600],
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
                                    color: emeraldColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: emeraldColor.withValues(alpha: 0.3), width: 1),
                                  ),
                                  child: Row(
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
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _isBalanceHidden ? '••••••' : '\$14,570.80',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
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
                                    color: emeraldColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_drop_up, color: emeraldColor, size: 14),
                                      const Text(
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
                    // PORTFOLIO CARDS SECTION
                    // ====================================================================
                    PortfolioCard(
                      fiatBalance: userAccount.balance,
                      fiatAccountNumber: userAccount.lastFourDigits,
                      cryptoBalance: 0.844,
                      cryptoSymbol: 'ETH',
                      cryptoFiatValue: 2120.80,
                      cryptoAddress: '0x7a...4e9f',
                      isBalanceHidden: _isBalanceHidden,
                      onFiatTap: () {},   
                      onCryptoTap: () {}, 
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(context, Icons.call_made, 'Send', Colors.blueAccent, const Placeholder()),
                        _buildActionButton(context, Icons.call_received, 'Receive', emeraldColor, const Placeholder()),
                        _buildActionButton(context, Icons.swap_horiz, 'Swap', Colors.purpleAccent, const Placeholder()),
                        _buildActionButton(context, Icons.account_balance_wallet, 'CashOut', Colors.orangeAccent, const Placeholder()),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                    _buildLedgerRow(context, Icons.movie_filter, Colors.blueAccent, 'Netflix Subscription', 'Debit Card • 2 mins ago', '-\$14.99', false),
                    _buildLedgerRow(context, Icons.token, Colors.purpleAccent, 'Minted NFT #4412', 'Status: Confirmed • 15 mins ago', '-0.002 ETH', true),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color accentColor, Widget? targetScreen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (targetScreen == null) return;
        widget.onNavigateToSubScreen(targetScreen);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[950] : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: TextStyle(
              color: theme.colorScheme.onSurface, 
              fontSize: 12, 
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(BuildContext context, IconData icon, Color iconColor, String title, String subtitle, String amount, bool isCrypto) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[950] : Colors.grey[50], 
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