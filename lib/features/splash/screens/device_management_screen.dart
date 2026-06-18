// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionDeviceModel {
  final String id;
  final String platformName;
  final String deviceHardware;
  final String locationScope;
  final String activeTime;
  final bool isCurrentSession;

  SessionDeviceModel({
    required this.id,
    required this.platformName,
    required this.deviceHardware,
    required this.locationScope,
    required this.activeTime,
    this.isCurrentSession = false,
  });
}

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final List<SessionDeviceModel> _activeSessions = [
    SessionDeviceModel(
      id: "SESS-01",
      platformName: "Web Workspace (Localhost)",
      deviceHardware: "Chrome Browser OS • Windows 11",
      locationScope: "Port Harcourt, Nigeria",
      activeTime: "Active Now",
      isCurrentSession: true,
    ),
    SessionDeviceModel(
      id: "SESS-02",
      platformName: "Mobile Engine App Client",
      deviceHardware: "Apple iPhone 15 Pro Max",
      locationScope: "Lagos, Nigeria",
      activeTime: "Last active: 2 hours ago",
    ),
    SessionDeviceModel(
      id: "SESS-03",
      platformName: "Cloud Endpoint API Link",
      deviceHardware: "Linux Kernel Core Server",
      locationScope: "Abuja, Nigeria",
      activeTime: "Last active: June 14, 2026",
    ),
  ];

  void _revokeDeviceAllocation(
    SessionDeviceModel targetDevice,
    Color bg,
    Color text,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Revoke Active Session?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        content: Text(
          'This will instantly destroy access tokens on the target instance and force an automated sign-out boundary reset loop.',
          style: TextStyle(fontSize: 12, height: 1.4, color: text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Access', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _activeSessions.removeWhere(
                  (element) => element.id == targetDevice.id,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Token key revoked securely.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Revoke Immediately',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme palette mappings
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardBg = isDark ? const Color(0xFF111622) : Colors.grey[100];
    final cardBorder = isDark ? const Color(0xFF1C2436) : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: titleColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Device Allocations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'Authorized Device Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review active authorization channels. You can terminate remote configurations instantly down below.',
              style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.3),
            ),
            const SizedBox(height: 24),

            ..._activeSessions.map(
              (session) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (session.isCurrentSession
                                    ? const Color(0xFF10B981)
                                    : Colors.grey)
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        session.isCurrentSession
                            ? Icons.phonelink_lock_rounded
                            : Icons.devices_other_rounded,
                        color: session.isCurrentSession
                            ? const Color(0xFF10B981)
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                session.platformName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              if (session.isCurrentSession) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.deviceHardware,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.locationScope,
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            session.activeTime,
                            style: TextStyle(
                              fontSize: 10,
                              color: session.isCurrentSession
                                  ? const Color(0xFF10B981)
                                  : subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!session.isCurrentSession)
                      IconButton(
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _revokeDeviceAllocation(
                          session,
                          cardBg!,
                          titleColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
