// lib/features/dashboard/presentation/screens/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final Stream<List<Map<String, dynamic>>> _analysisStream;
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    // 🚀 FIXED: Isolated pipeline connection initialized exactly once
    if (_currentUserId != null) {
      _analysisStream = Supabase.instance.client
          .from('balance_audit_logs')
          .stream(primaryKey: ['id'])
          .eq('user_id', _currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Live Reports & Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _currentUserId == null
          ? const Center(child: Text('User not authenticated'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _analysisStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error rendering data.'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final data = snapshot.data ?? [];
                double liveTotalIncome = 0;
                double liveTotalExpenses = 0;

                for (var tx in data) {
                  final amt = (tx['ngn_balance'] ?? 0.0).toDouble();
                  if (tx['source'] == 'flutterwave_sync' || tx['source'] == 'deposit') {
                    liveTotalIncome += amt;
                  } else {
                    liveTotalExpenses += amt;
                  }
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildLiveCard('Inflow Metrics', '₦${liveTotalIncome.toStringAsFixed(2)}', Colors.green, cardColor!)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildLiveCard('Outflow Metrics', '₦${liveTotalExpenses.toStringAsFixed(2)}', Colors.redAccent, cardColor)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                      child: Text('Total Dynamic Data Logs Evaluated: ${data.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                );
              },
            ),
    );
  }

  Widget _buildLiveCard(String title, String value, Color color, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}