// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'account_statement_screen.dart';

// Brand Identity Color Palette
const Color brandDeepBg = Color(0xFF0A0A0C);
const Color brandCardBg = Color(0xFF111622);
const Color brandPurpleColor = Color(0xFF8B5CF6);
const Color brandAccentColor = Color(0xFF10B981);
const Color brandRedColor = Color(0xFFEF4444);

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isLoading = false;
  String _searchQuery = '';

  // Dummy Unified Ledger Array representing custom unified category maps compiled from Supabase Stream channels.
  // Replace this placeholder payload with your active Supabase stream events integration.
  final List<Map<String, dynamic>> _unifiedLedger = [
    {
      'title': 'P2P Transfer Sent',
      'subtitle': 'TX-HASH: 0x8a1b...2c4d',
      'date': '2026-07-10T14:32:00.000Z',
      'amount': '-\$250.00',
      'isIncome': false,
      'isCrypto': true,
      'type': 'send',
      'peerName': 'Alex Rivera',
      'channelLabel': 'Ethereum Mainnet',
      'accountInfo': '0x71C...39b2',
      'status': 'Success',
      'icon': Icons.swap_horiz,
      'iconColor': brandRedColor,
      'ticker': 'USDT'
    },
    {
      'title': 'USDC Swap Executed',
      'subtitle': 'USDT to USDC Swap Engine',
      'date': '2026-07-08T09:15:00.000Z',
      'amount': '+\$1,200.00',
      'isIncome': true,
      'isCrypto': true,
      'type': 'swap',
      'peerName': 'Uniswap Router',
      'channelLabel': 'Polygon Chain',
      'accountInfo': '0x71C...39b2',
      'status': 'Success',
      'icon': Icons.currency_exchange,
      'iconColor': brandAccentColor,
      'ticker': 'USDC'
    },
    {
      'title': 'Bank Wire Deposit',
      'subtitle': 'Ref: ACH-992182-USD',
      'date': '2026-07-05T18:45:00.000Z',
      'amount': '+\$5,000.00',
      'isIncome': true,
      'isCrypto': false,
      'type': 'deposit',
      'peerName': 'Apex Clearing Corp',
      'channelLabel': 'Plaid API',
      'accountInfo': 'Chase Bank (****4829)',
      'status': 'Success',
      'icon': Icons.account_balance,
      'iconColor': brandAccentColor,
      'ticker': 'USD'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? brandDeepBg : theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? brandCardBg : Colors.grey[100]!;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    final filteredLedger = _unifiedLedger.where((tx) {
      final title = tx['title'].toString().toLowerCase();
      final subtitle = tx['subtitle'].toString().toLowerCase();
      final peer = tx['peerName'].toString().toLowerCase();
      final acc = tx['accountInfo'].toString().toLowerCase();
      final chn = tx['channelLabel'].toString().toLowerCase();
      final tck = tx['ticker'].toString().toLowerCase();
      final searchLower = _searchQuery.toLowerCase();

      return title.contains(searchLower) || 
             subtitle.contains(searchLower) ||
             peer.contains(searchLower) ||
             acc.contains(searchLower) ||
             chn.contains(searchLower) ||
             tck.contains(searchLower);
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Unified Transaction Ledger',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? brandCardBg : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Navigates directly to the statement builder with compiled live data passed over!
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF10B981)),
            tooltip: 'Get Account Statement',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountStatementScreen(
                    initialTransactions: _unifiedLedger,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isDark ? brandPurpleColor : const Color(0xFF8B5CF6),
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: isDark ? brandPurpleColor : const Color(0xFF8B5CF6),
          tabs: const [
            Tab(text: 'All Activity'),
            Tab(text: 'Deposits'),
            Tab(text: 'Swaps'),
            Tab(text: 'P2P Sent'),
            Tab(text: 'P2P Received'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandPurpleColor))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: isDark ? brandDeepBg : Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? brandCardBg : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.05 : 0.2)),
                    ),
                    child: TextField(
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: isDark ? Colors.grey : Colors.grey[600], size: 20),
                        hintText: 'Search peer name, coin, account or reference...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLedgerList(filteredLedger, cardColor, textColor, secondaryTextColor, isDark),
                      _buildLedgerList(filteredLedger.where((tx) => tx['type'] == 'deposit').toList(), cardColor, textColor, secondaryTextColor, isDark),
                      _buildLedgerList(filteredLedger.where((tx) => tx['type'] == 'swap').toList(), cardColor, textColor, secondaryTextColor, isDark),
                      _buildLedgerList(filteredLedger.where((tx) => tx['type'] == 'send').toList(), cardColor, textColor, secondaryTextColor, isDark),
                      _buildLedgerList(filteredLedger.where((tx) => tx['type'] == 'receive').toList(), cardColor, textColor, secondaryTextColor, isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLedgerList(
    List<Map<String, dynamic>> items,
    Color cardColor,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No transactions found.',
          style: TextStyle(color: secondaryColor),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tx = items[index];

        return InkWell(
          onTap: () {
            // Reusing the dialog interface internally for quick review directly from ledger
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountStatementScreen(
                  initialTransactions: _unifiedLedger,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.05 : 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tx['icon'], color: tx['iconColor'], size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'],
                        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx['subtitle'],
                        style: TextStyle(color: secondaryColor, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(tx['date']),
                        style: TextStyle(color: Colors.grey[500], fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tx['amount'],
                  style: TextStyle(
                    color: tx['isIncome'] ? brandAccentColor : brandRedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}