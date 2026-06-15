// ignore_for_file: unused_local_variable, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SystemLogModel {
  final String title;
  final String type; // 'Maintenance', 'Update', 'Outage', 'Feature'
  final String timestamp;
  final String body;
  final bool isActiveIssue;

  SystemLogModel({
    required this.title,
    required this.type,
    required this.timestamp,
    required this.body,
    this.isActiveIssue = false,
  });
}

class StatusAnnouncementsScreen extends StatefulWidget {
  const StatusAnnouncementsScreen({super.key});

  @override
  State<StatusAnnouncementsScreen> createState() => _StatusAnnouncementsScreenState();
}

class _StatusAnnouncementsScreenState extends State<StatusAnnouncementsScreen> {
  // Mock live operational stream matching requirements exactly
  final List<SystemLogModel> _feedLogs = [
    SystemLogModel(
      title: 'Emergency Core Gateway Maintenance',
      type: 'Maintenance',
      timestamp: 'Today, 04:15 PM',
      body: 'Scheduled scaling optimization patches will roll out to node nodes tonight between 02:00 AM and 03:00 AM UTC. Expect minor database handoff pauses lasting under 45 seconds.',
    ),
    SystemLogModel(
      title: 'Biometric Access Pipeline Upgraded v3.4.0',
      type: 'Update',
      timestamp: 'Yesterday, 10:30 AM',
      body: 'Our latest mobile build patch has fully integrated automated asynchronous validation gaps across active user context profiles to protect session allocations.',
    ),
    SystemLogModel(
      title: 'Card Settlement Gateway Degradation',
      type: 'Outage',
      timestamp: 'June 10, 2026',
      body: 'Intermittent third-party payment rail drop-offs are causing temporary timeout responses on local Visa debit networks. Card networks are actively deploying a fix.',
      isActiveIssue: true,
    ),
    SystemLogModel(
      title: 'Split-Bill Hub Feature Now Live',
      type: 'Feature',
      timestamp: 'June 08, 2026',
      body: 'You can now select multiple transaction line-items directly out of your wallet ledger and distribute live payment collection codes instantly to external phone numbers.',
    ),
  ];

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'Outage': return Colors.redAccent;
      case 'Maintenance': return Colors.amber[700]!;
      case 'Update': return const Color(0xFF3B82F6);
      case 'Feature': return const Color(0xFF10B981);
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'Outage': return Icons.gpp_bad_rounded;
      case 'Maintenance': return Icons.build_circle_outlined;
      case 'Update': return Icons.system_update_alt_rounded;
      case 'Feature': return Icons.auto_awesome_motion_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'System Status & Notices',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            // Live Status Hero Dashboard Health Shield Indicator
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF10B981),
                    radius: 6,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('All Primary Core Engine Services Operational', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Operational monitoring registers optimal integrity levels.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Operational Feed & Logs',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 12),

            // Main Status / Announcement Loop
            ..._feedLogs.map((log) {
              final statusColor = _getCategoryColor(log.type);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: log.isActiveIssue ? statusColor.withOpacity(0.04) : cardBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: log.isActiveIssue ? statusColor.withOpacity(0.4) : cardBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(log.type), size: 12, color: statusColor),
                              const SizedBox(width: 6),
                              Text(
                                log.type.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                        Text(log.timestamp, style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      log.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log.body,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}