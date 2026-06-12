// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fintech/features/dashboard/presentation/screens/more_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDateRange = 'Last 30 Days';

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Netflix Subscription',
      'subtitle': 'Debit Card • Visa (*8921)',
      'amount': '-\$14.99',
      'date': DateTime.now().subtract(const Duration(minutes: 2)),
      'isCrypto': false,
      'icon': Icons.movie_filter,
      'iconColor': Colors.blueAccent,
    },
    {
      'title': 'Minted NFT #4412',
      'subtitle': 'Wallet: 0x7a...4e9f',
      'amount': '-0.002 ETH',
      'date': DateTime.now().subtract(const Duration(minutes: 15)),
      'isCrypto': true,
      'icon': Icons.token,
      'iconColor': Colors.purpleAccent,
    },
    {
      'title': 'Funds Deposit',
      'subtitle': 'Bank Transfer via Add Money',
      'amount': '+\$500.00',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'isCrypto': false,
      'icon': Icons.arrow_downward,
      'iconColor': const Color(0xFF10B981),
    },
    {
      'title': 'Swapped USDT to ETH',
      'subtitle': 'Uniswap V3 Protocol',
      'amount': '+0.15 ETH',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'isCrypto': true,
      'icon': Icons.swap_horiz,
      'iconColor': Colors.deepPurpleAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerStatementDownload() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Safe, localized execution context inside timer frame closure
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          
          // Dismiss the specific dialog layer via its distinct build context context
          Navigator.of(dialogContext).pop();

          // Safely target root layout framework to notify the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Statement downloaded successfully ($_selectedDateRange)',
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
            color: theme.colorScheme.primary != theme.scaffoldBackgroundColor 
                ? theme.colorScheme.primary 
                : const Color(0xFF8B5CF6),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[100];
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[300]!;
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Solves unclickable elements by decoupling layout context and adding target fallbacks
        leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
  onPressed: () {
    // 1. Try a global router pop first
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      // 2. If stuck in a shell, force GoRouter to explicitly target the root location
      // If your GoRouter setup uses a sub-route layout like '/dashboard/more', use that path here instead.
      context.go('/dashboard'); 
    }
  },
),
        title: Text(
          'Account Statement', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _showDateRangePicker(context),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ====================================================================
            // CONSOLIDATED OVERVIEW SUMMARY CHIP
            // ====================================================================
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
                          'Selected Timeline Range',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedDateRange,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _triggerStatementDownload,
                    icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF10B981)),
                    label: const Text('Export', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // ====================================================================
            // SEGMENTED LEDGER CONTROL FILTER TABS
            // ====================================================================
            TabBar(
              controller: _tabController,
              indicatorColor: accentPrimaryColor,
              labelColor: theme.colorScheme.onSurface,
              unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: const [
                Tab(text: 'All Activity'),
                Tab(text: 'Fiat'),
                Tab(text: 'Web3'),
              ],
            ),
            const SizedBox(height: 8),

            // ====================================================================
            // FILTERED TRANSACTION LISTS BUILDER
            // ====================================================================
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionListView(_allTransactions),
                  _buildTransactionListView(_allTransactions.where((tx) => tx['isCrypto'] == false).toList()),
                  _buildTransactionListView(_allTransactions.where((tx) => tx['isCrypto'] == true).toList()),
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
          'No transaction logs available for this period.', 
          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
        ),
      );
    }

    final tileBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final tileBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final internalIconBgColor = isDark ? Colors.black38 : Colors.white;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final DateTime dateValue = tx['date'];

        return Container(
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
                  color: internalIconBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? null : Border.all(color: Colors.grey[200]!),
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
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx['subtitle'],
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][dateValue.month - 1]} ${dateValue.day.toString().padLeft(2, '0')}, ${dateValue.year} • ${dateValue.hour % 12 == 0 ? 12 : dateValue.hour % 12}:${dateValue.minute.toString().padLeft(2, '0')} ${dateValue.hour >= 12 ? 'PM' : 'AM'}',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tx['amount'],
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
      },
    );
  }

  void _showDateRangePicker(BuildContext context) {
    final List<String> ranges = ['Today', 'Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'Custom Range'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

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
                  'Select Statement Range', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              ...ranges.map((range) => ListTile(
                    title: Text(
                      range, 
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                    ),
                    trailing: _selectedDateRange == range ? Icon(Icons.check, color: accentPrimaryColor) : null,
                    onTap: () {
                      setState(() {
                        _selectedDateRange = range;
                      });
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