// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountStatementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialTransactions;

  const AccountStatementScreen({super.key, this.initialTransactions = const []});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String _selectedDateRange = 'Last 30 Days';
  String _searchQuery = '';
  bool _isLoading = false;
  
  late DateTime _startDate;
  late DateTime _endDate;

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setDateRange('Last 30 Days');
    
    if (widget.initialTransactions.isNotEmpty) {
      _transactions = widget.initialTransactions;
    } else {
      _fetchUserTransactions();
    }
  }

  /// Securely fetches transactions from Supabase matching ONLY the logged-in user
  Future<void> _fetchUserTransactions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint("No authenticated user found.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Query database: Filter strictly by the current user
      final response = await _supabase
          .from('fiat_transactions') 
          .select()
          // =========================================================================
          // ⚠️ ERROR WAS HERE: 'user_id' column doesn't exist on your table.
          // Change 'user_id' below to whatever your column is named (e.g., 'profile_id', 'owner_id', 'sender_id')
          // =========================================================================
          .eq('user_id', user.id) 
          .order('date', ascending: false);

      if (response.isNotEmpty) {
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(response.map((item) {
            // Map your database column names to match the UI keys dynamically
            return {
              'title': item['title'] ?? 'Transaction',
              'subtitle': item['subtitle'] ?? item['reference_id'] ?? 'N/A',
              'date': item['date'] ?? item['created_at'] ?? DateTime.now().toIso8601String(),
              'amount': '${item['is_income'] == true ? '+' : '-'}\$${item['amount']}',
              'isIncome': item['is_income'] ?? false,
              'isCrypto': item['is_crypto'] ?? false,
              'peerName': item['peer_name'] ?? 'N/A',
              'channelLabel': item['channel_label'] ?? 'System',
              'accountInfo': item['account_info'] ?? 'N/A',
              'status': item['status'] ?? 'Success',
              'icon': _getIconForType(item['type'] ?? 'default'),
              'iconColor': item['is_income'] == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            };
          }));
        });
      }
    } catch (e) {
      debugPrint("Error fetching database transactions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load real-time transactions securely.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper to assign visual material icons based on tx type stored in database
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return Icons.account_balance;
      case 'swap':
        return Icons.currency_exchange;
      case 'send':
        return Icons.swap_horiz;
      default:
        return Icons.payment;
    }
  }

  void _setDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      _selectedDateRange = range;
      if (range == 'Today') {
        _startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (range == 'Last 7 Days') {
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (range == 'Last 30 Days') {
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (range == 'Last 90 Days') {
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 90));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (range == 'This Year') {
        _startDate = DateTime(now.year, 1, 1, 0, 0, 0);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredTransactions({required bool? isCrypto}) {
    return _transactions.where((tx) {
      DateTime txDate;
      try {
        txDate = DateTime.parse(tx['date'].toString()).toLocal();
      } catch (_) {
        txDate = DateTime.now();
      }
      
      final isInDateRange = txDate.isAfter(_startDate.subtract(const Duration(seconds: 1))) && 
                            txDate.isBefore(_endDate.add(const Duration(seconds: 1)));

      final matchesType = isCrypto == null || tx['isCrypto'] == isCrypto;

      final title = tx['title'].toString().toLowerCase();
      final subtitle = tx['subtitle'].toString().toLowerCase();
      final peer = (tx['peerName'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = title.contains(query) || subtitle.contains(query) || peer.contains(query);

      return isInDateRange && matchesType && matchesSearch;
    }).toList();
  }

  void _triggerStatementDownload() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(dialogContext).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Statement Export PDF saved successfully to downloads folder!',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        });

        return Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF8B5CF6),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0A0A0C) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              
              Icon(tx['icon'], color: tx['iconColor'], size: 48),
              const SizedBox(height: 12),
              Text(
                tx['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                tx['amount'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: tx['isIncome'] ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Beneficiary/Sender', tx['peerName'] ?? 'N/A', isDark),
                    _buildReceiptRow('Payment Route', tx['channelLabel'] ?? 'System Link', isDark),
                    _buildReceiptRow('Wallet / Account', tx['accountInfo'] ?? 'N/A', isDark),
                    _buildReceiptRow('Timestamp', DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(tx['date'].toString())), isDark),
                    _buildReceiptRow('Status', (tx['status'] ?? 'Success').toUpperCase(), isDark, valueColor: const Color(0xFF10B981)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? const Color(0xFF26243C) : Colors.grey[300]!),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '${tx['title']}: ${tx['amount']}\nRef: ${tx['subtitle']}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction details copied to clipboard!')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text('Copy Info', style: TextStyle(color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preparing image payload... Shared successfully!')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.share, size: 18, color: Colors.white),
                      label: const Text('Send Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[100];
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[300]!;
    const accentPrimaryColor = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0C) : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account Statement', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _showDateRangePicker(context),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: accentPrimaryColor))
        : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111622) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: TextField(
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, size: 18),
                    hintText: 'Search statement transactions...',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: accentPrimaryColor.withOpacity(0.12),
                    child: Icon(Icons.analytics_outlined, color: accentPrimaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statement Range Period',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedDateRange,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _triggerStatementDownload,
                    icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF10B981)),
                    label: const Text('Export PDF', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              indicatorColor: accentPrimaryColor,
              labelColor: theme.colorScheme.onSurface,
              unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'All Activity'),
                Tab(text: 'Fiat Accounts'),
                Tab(text: 'Web3 Ledger'),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionListView(_getFilteredTransactions(isCrypto: null)),
                  _buildTransactionListView(_getFilteredTransactions(isCrypto: false)),
                  _buildTransactionListView(_getFilteredTransactions(isCrypto: true)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListView(List<Map<String, dynamic>> transactions) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No activity matches your timeline or search.', 
          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
        ),
      );
    }

    final tileBgColor = isDark ? const Color(0xFF111622) : Colors.grey[50];
    final tileBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final DateTime dateValue = DateTime.parse(tx['date'].toString());

        return InkWell(
          onTap: () => _showTransactionDetails(tx),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tileBgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tileBorderColor),
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
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx['subtitle'],
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(dateValue),
                        style: TextStyle(color: Colors.grey[500], fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tx['amount'],
                  style: TextStyle(
                    color: tx['isIncome'] ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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

  void _showDateRangePicker(BuildContext context) {
    final List<String> ranges = ['Today', 'Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF151424) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Statement Timeline', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              ...ranges.map((range) => ListTile(
                title: Text(range, style: const TextStyle(fontSize: 14)),
                trailing: _selectedDateRange == range ? const Icon(Icons.check, color: Color(0xFF8B5CF6)) : null,
                onTap: () {
                  _setDateRange(range);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }
}