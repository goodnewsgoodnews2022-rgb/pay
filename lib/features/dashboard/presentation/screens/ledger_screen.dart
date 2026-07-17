// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isLoading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _unifiedLedger = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      // Corrected to 'fiat_transactions' based on your console error
      final data = await Supabase.instance.client
          .from('fiat_transactions')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _unifiedLedger = (data as List<dynamic>).map((tx) {
          // Assuming 'amount' is a number in your DB
          final val = double.tryParse(tx['amount'].toString()) ?? 0.0;
          final isIncome = val >= 0;
          
          return {
            'title': tx['type']?.toString().toUpperCase() ?? 'TRANSACTION',
            'subtitle': tx['reference'] ?? 'No ref',
            'date': tx['created_at'] ?? DateTime.now().toIso8601String(),
            'amount': (isIncome ? '+' : '') + val.toStringAsFixed(2),
            'isIncome': isIncome,
            'type': tx['type'] ?? 'other', 
            'icon': _getIconForType(tx['type']),
            'iconColor': isIncome ? brandAccentColor : brandRedColor,
            'ticker': tx['ticker'] ?? 'USD',
            'peerName': tx['peer_name'] ?? 'N/A',
            'channelLabel': tx['channel'] ?? 'N/A',
            'accountInfo': tx['account_info'] ?? 'N/A',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching ledger: $e");
      setState(() => _isLoading = false);
    }
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'deposit': return Icons.account_balance;
      case 'swap': return Icons.currency_exchange;
      case 'send': return Icons.call_made;
      case 'receive': return Icons.call_received;
      default: return Icons.swap_horiz;
    }
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
      final searchLower = _searchQuery.toLowerCase();
      return tx['title'].toString().toLowerCase().contains(searchLower) || 
             tx['subtitle'].toString().toLowerCase().contains(searchLower);
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Unified Transaction Ledger', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: isDark ? brandCardBg : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF10B981)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountStatementScreen())),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isDark ? brandPurpleColor : const Color(0xFF8B5CF6),
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: isDark ? brandPurpleColor : const Color(0xFF8B5CF6),
          tabs: const [Tab(text: 'All Activity'), Tab(text: 'Deposits'), Tab(text: 'Swaps'), Tab(text: 'P2P Sent'), Tab(text: 'P2P Received')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandPurpleColor))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? brandCardBg : Colors.grey[50],
                      hintText: 'Search peer name, coin, account or reference...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
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

  Widget _buildLedgerList(List<Map<String, dynamic>> items, Color cardColor, Color textColor, Color secondaryColor, bool isDark) {
    if (items.isEmpty) return Center(child: Text('No transactions found.', style: TextStyle(color: secondaryColor)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tx = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(tx['icon'], color: tx['iconColor'], size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['title'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(tx['subtitle'], style: TextStyle(color: secondaryColor, fontSize: 11)),
                    Text(_formatDateTime(tx['date']), style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                  ],
                ),
              ),
              Text(tx['amount'], style: TextStyle(color: tx['isIncome'] ? brandAccentColor : brandRedColor, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
        );
      },
    );
  }
}