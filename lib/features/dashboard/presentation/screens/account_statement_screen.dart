// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _allTransactions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      
      // Fetching strictly from the database table mapped to the current user
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_identifier', currentUserId ?? '')
          .order('created_at', ascending: false);

      setState(() {
        _allTransactions = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _filterTransactions() {
    return _allTransactions.where((tx) {
      final dateStr = tx['created_at'] != null 
          ? DateFormat.yMMMM().format(DateTime.parse(tx['created_at'])).toLowerCase() 
          : '';
      final query = _searchQuery.toLowerCase();
      
      final typeStr = tx['type']?.toString().toLowerCase() ?? '';
      final matchesSearch = dateStr.contains(query) || typeStr.contains(query);
      
      return matchesSearch;
    }).toList();
  }

  Future<void> _exportAndShare(List<Map<String, dynamic>> filteredData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Stack(
          children: [
            pw.Center(
              child: pw.Transform.rotate(
                angle: 0.8,
                child: pw.Text(
                  "Pay Me",
                  style: pw.TextStyle(
                    fontSize: 100,
                    color: PdfColors.grey200,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Column(
              children: [
                pw.Header(level: 0, child: pw.Text("Account Statement")),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Type', 'Date', 'Amount'],
                  data: filteredData.map((t) => [
                    t['type']?.toString().toUpperCase() ?? 'N/A',
                    t['created_at'] != null ? t['created_at'].toString().substring(0, 10) : 'N/A',
                    'NGN ${(t['amount'] ?? 0.0).toStringAsFixed(2)}'
                  ]).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Adaptive theme tokens
    final canvasColor = isDark ? const Color(0xFF0A0A0C) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF161618) : Colors.white;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey : const Color(0xFF64748B);
    const accentColor = Colors.purpleAccent;

    final filteredData = _filterTransactions();

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Statement", 
          style: TextStyle(fontWeight: FontWeight.bold, color: mainTextColor, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: mainTextColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: mainTextColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: surfaceColor,
                hintText: "Search by month (e.g. june 2026) or type...",
                hintStyle: TextStyle(color: secondaryTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide(
                    color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide(
                    color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: accentColor))
                : filteredData.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: secondaryTextColor, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredData.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final tx = filteredData[i];
                          final type = tx['type']?.toString().toUpperCase() ?? 'TRANSACTION';
                          final amount = (tx['amount'] ?? 0.0).toDouble();
                          final date = tx['created_at'] != null ? tx['created_at'].toString().substring(0, 10) : '';

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.15),
                              ),
                              boxShadow: !isDark 
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.receipt_long_rounded, color: Colors.purpleAccent, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(
                                        type, 
                                        style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date, 
                                        style: TextStyle(color: secondaryTextColor, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "NGN ${(amount ?? 0.0).toStringAsFixed(2)}",
                                  style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        onPressed: () => _exportAndShare(filteredData),
        label: const Text("Export PDF", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}