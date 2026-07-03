// lib/features/dashboard/presentation/screens/ledger_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  late final Stream<List<Map<String, dynamic>>> _ledgerStream;
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    // 🚀 CACHED STREAM REFERENCE: Prevents the app from choking the main thread
    if (_currentUserId != null) {
      _ledgerStream = Supabase.instance.client
          .from('balance_audit_logs')
          .stream(primaryKey: ['id'])
          .eq('user_id', _currentUserId)
          .order('synced_at', ascending: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Official Ledger Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentUserId == null
            ? const Center(child: Text('User not authenticated'))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _ledgerStream, // Uses the cached stream
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Connection error.'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                  }

                  final ledgerData = snapshot.data ?? [];
                  if (ledgerData.isEmpty) {
                    return const Center(child: Text('No records found.', style: TextStyle(color: Colors.grey)));
                  }

                  return Container(
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Amount')),
                          ],
                          rows: ledgerData.map((tx) {
                            final String dateString = tx['synced_at'] ?? tx['created_at'] ?? '';
                            final String formattedDate = dateString.length >= 10 ? dateString.substring(5, 10) : '—';
                            final double amount = ((tx['ngn_balance'] ?? tx['amount'] ?? 0.0) as num).toDouble();
                            final String description = tx['source'] ?? 'Transaction';

                            return DataRow(cells: [
                              DataCell(Text(formattedDate)),
                              DataCell(Text(description.toUpperCase())),
                              DataCell(Text('₦${amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}