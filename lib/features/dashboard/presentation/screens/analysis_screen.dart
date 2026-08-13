// lib/features/dashboard/presentation/screens/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late final Stream<List<Map<String, dynamic>>> _analysisStream;
  late TabController _timeframeController;

  @override
  void initState() {
    super.initState();
    _timeframeController = TabController(length: 4, vsync: this);
    _timeframeController.addListener(() {
      setState(() {}); 
    });

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // ✅ Correctly fetching stream filtered strictly by current logged-in user
    _analysisStream = Supabase.instance.client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_identifier', currentUserId ?? '')
        .order('created_at', ascending: false);
  }

  @override
  void dispose() {
    _timeframeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    
    const Color brandPurple = Color(0xFF8B5CF6);
    const Color emeraldGreen = Color(0xFF10B981); // Received
    const Color warningRed = Color(0xFFEF4444);    // Sent
    const Color blueWithdraw = Color(0xFF3B82F6);  // Withdrawals
    const Color amberSwap = Color(0xFFFBBF24);     // Swaps

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Live Portfolio Metrics', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _timeframeController,
          labelColor: brandPurple,
          unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
          indicatorColor: brandPurple,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _analysisStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Data allocation evaluation mismatch.', style: TextStyle(color: textColor)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brandPurple));
          }

          final rawData = snapshot.data ?? [];
          final metrics = _calculateMetrics(rawData, _timeframeController.index);

          // Combined unified volume metrics
          final double totalReceived = metrics.received;
          final double totalSent = metrics.sent;
          final double totalWithdraw = metrics.withdraw;
          final double totalSwap = metrics.swap;
          final double totalVolume = totalReceived + totalSent + totalWithdraw + totalSwap;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // 📊 PREMIUM CUSTOM GRAPHIC PIE/DONUT CHART ARCHITECTURE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TRANSACTION DISTRIBUTION',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Vectorized Chart Element Rendering Canvas
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CustomPaint(
                              painter: _FintechPieChartPainter(
                                values: [totalReceived, totalSent, totalWithdraw, totalSwap],
                                colors: [emeraldGreen, warningRed, blueWithdraw, amberSwap],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Volume',
                                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      totalVolume > 9999 ? "₦${(totalVolume / 1000).toStringAsFixed(1)}k" : "₦${totalVolume.toStringAsFixed(0)}",
                                      style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Dynamic Chart Indicators Map Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIndicator(emeraldGreen, 'Received', totalReceived, totalVolume),
                              const SizedBox(height: 8),
                              _buildIndicator(warningRed, 'Sent Out', totalSent, totalVolume),
                              const SizedBox(height: 8),
                              _buildIndicator(blueWithdraw, 'Withdrawn', totalWithdraw, totalVolume),
                              const SizedBox(height: 8),
                              _buildIndicator(amberSwap, 'Swapped', totalSwap, totalVolume),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Numerical Summaries Information Block Grid Layout Structure
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildMetricCard('Total Received', totalReceived, emeraldGreen, cardColor, textColor, Icons.arrow_downward_rounded),
                    _buildMetricCard('Total Sent', totalSent, warningRed, cardColor, textColor, Icons.arrow_upward_rounded),
                    _buildMetricCard('Withdrawals', totalWithdraw, blueWithdraw, cardColor, textColor, Icons.account_balance_wallet_rounded),
                    _buildMetricCard('Asset Swaps', totalSwap, amberSwap, cardColor, textColor, Icons.swap_horizontal_circle_rounded),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  'REAL-TIME ACCOUNT STREAM BREAKDOWN',
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                metrics.filteredItems.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                        child: Center(
                          child: Text(
                            'No recorded database data logs mapped for this timeframe.',
                            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: metrics.filteredItems.length,
                        itemBuilder: (context, index) {
                          final log = metrics.filteredItems[index];
                          final String type = (log['type'] ?? '').toString().toLowerCase();
                          final double amt = (log['amount'] ?? 0.0).toDouble();

                          Color actionColor = emeraldGreen;
                          IconData actionIcon = Icons.arrow_downward_rounded;
                          if (type.contains('p2p outbound') || type.contains('transfer out') || type.contains('send')) {
                            actionColor = warningRed;
                            actionIcon = Icons.arrow_upward_rounded;
                          } else if (type.contains('withdrawal')) {
                            actionColor = blueWithdraw;
                            actionIcon = Icons.account_balance_rounded;
                          } else if (type.contains('swap')) {
                            actionColor = amberSwap;
                            actionIcon = Icons.swap_horiz_rounded;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor, 
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: actionColor.withValues(alpha: 0.1),
                                      radius: 20,
                                      child: Icon(actionIcon, color: actionColor, size: 18),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          type.toUpperCase().replaceAll('_', ' '),
                                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log['created_at'] != null ? log['created_at'].toString().substring(0, 10) : '',
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  "₦${amt.toStringAsFixed(2)}",
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator(Color color, String label, double val, double total) {
    final double percentage = total > 0 ? (val / total) * 100 : 0.0;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
            Text(
              "₦${val.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, double amount, Color accentColor, Color cardBg, Color txtColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
              Icon(icon, color: accentColor, size: 16),
            ],
          ),
          Text(
            "₦${amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: txtColor, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }

  _ProcessedFintechMetrics _calculateMetrics(List<Map<String, dynamic>> logs, int timeframeIndex) {
    double received = 0.0, sent = 0.0, withdraw = 0.0, swap = 0.0;
    List<Map<String, dynamic>> filteredList = [];
    final now = DateTime.now();

    for (var log in logs) {
      if (log['created_at'] == null) continue;
      final logDate = DateTime.parse(log['created_at'].toString());
      bool isInTimeframe = false;

      if (timeframeIndex == 0) {
        isInTimeframe = logDate.year == now.year && logDate.month == now.month && logDate.day == now.day;
      } else if (timeframeIndex == 1) {
        final oneWeekAgo = now.subtract(const Duration(days: 7));
        isInTimeframe = logDate.isAfter(oneWeekAgo) && logDate.isBefore(now.add(const Duration(days: 1)));
      } else if (timeframeIndex == 2) {
        isInTimeframe = logDate.year == now.year && logDate.month == now.month;
      } else if (timeframeIndex == 3) {
        isInTimeframe = logDate.year == now.year;
      }

      if (isInTimeframe) {
        filteredList.add(log);
        final String type = (log['type'] ?? '').toString().toLowerCase();
        final double amt = (log['amount'] ?? 0.0).toDouble();

        if (type.contains('deposit') || type.contains('inbound') || type.contains('receive')) {
          received += amt;
        } else if (type.contains('withdrawal')) {
          withdraw += amt;
        } else if (type.contains('swap')) {
          swap += amt;
        } else {
          sent += amt;
        }
      }
    }

    return _ProcessedFintechMetrics(
      received: received, sent: sent, withdraw: withdraw, swap: swap,
      filteredItems: filteredList,
    );
  }
}

// 🎨 HIGH PERFORMANCE MATHEMATICAL VECTOR PAINT ARCHITECTURE FOR THE PIE CHART
class _FintechPieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _FintechPieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0, (sum, val) => sum + val);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      paint.color = Colors.grey.withValues(alpha: 0.2);
      canvas.drawCircle(center, radius - 2, paint);
      return;
    }

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ProcessedFintechMetrics {
  final double received;
  final double sent;
  final double withdraw;
  final double swap;
  final List<Map<String, dynamic>> filteredItems;

  _ProcessedFintechMetrics({
    required this.received, 
    required this.sent, 
    required this.withdraw, 
    required this.swap,
    required this.filteredItems,
  });
}