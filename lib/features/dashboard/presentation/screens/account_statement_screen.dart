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

class _AccountStatementScreenState extends State<AccountStatementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _allTransactions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final response = await _supabase.from('fiat_transactions').select().order('created_at', ascending: false);
    setState(() => _allTransactions = List<Map<String, dynamic>>.from(response));
  }

  List<Map<String, dynamic>> _filterTransactions(String? category) {
    return _allTransactions.where((tx) {
      final date = DateTime.parse(tx['created_at']);
      final dateStr = DateFormat.yMMMM().format(date).toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      final matchesSearch = dateStr.contains(query) || 
                            tx['reference'].toString().toLowerCase().contains(query);
      
      if (category == null) return matchesSearch;
      return matchesSearch && (tx['category'] ?? 'fiat') == category;
    }).toList();
  }

  Future<void> _exportAndShare(List<Map<String, dynamic>> filteredData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Stack(
          children: [
            // Background Watermark layer
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
            // Content layer
            pw.Column(
              children: [
                pw.Header(level: 0, child: pw.Text("Account Statement")),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Type', 'Reference', 'Amount'],
                  data: filteredData.map((t) => [
                    t['type'].toString().toUpperCase(),
                    t['reference'].toString(),
                    t['amount'].toString()
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Statement", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'All'), Tab(text: 'Fiat'), Tab(text: 'Web3')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF161618),
                hintText: "Search by month (e.g. june 2026)...",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(_filterTransactions(null)),
                _buildListView(_filterTransactions('fiat')),
                _buildListView(_filterTransactions('web3')),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purpleAccent,
        onPressed: () => _exportAndShare(_filterTransactions(null)),
        label: const Text("Export PDF"),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final tx = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF161618), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.purpleAccent),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tx['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(tx['reference'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              const Spacer(),
              Text(tx['amount'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}