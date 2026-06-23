// lib/features/dashboard/presentation/screens/app_preferences_screen.dart

// ignore_for_file: prefer_const_constructors, unused_element, unused_field, implementation_imports, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ CRITICAL FIX: Import your main.dart file to gain access to the global themeStateProvider
import 'package:fintech/main.dart';

// ============================================
// 🔐 SECURE API KEY CONFIGURATION
// ============================================
class FlutterwaveConfig {
  // IMPORTANT: In production, NEVER hardcode API keys. Use environment variables
  // or secure storage. This is for demonstration purposes only.
  static const String secretKey = 'YOUR_FLUTTERWAVE_SECRET_KEY';
  static const String baseUrl = 'https://api.flutterwave.com/v3';
}

class AppPreferencesScreen extends ConsumerStatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  ConsumerState<AppPreferencesScreen> createState() =>
      _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends ConsumerState<AppPreferencesScreen> {
  // ============================================
  // 🏦 BALANCE STATE VARIABLES
  // ============================================
  double _ngnBalance = 0.0;
  bool _isLoadingBalances = false;
  String? _lastError;

  // Flutterwave wallet ID for NGN
  static const String _ngnWalletId = 'YOUR_NGN_WALLET_ID';

  // Supabase Realtime subscription
  late final Stream<List<Map<String, dynamic>>> _walletStream;

  @override
  void initState() {
    super.initState();
    _setupWalletStream();
    _fetchAllBalances();
  }

  // ============================================
  // 📡 SETUP SUPABASE REALTIME SUBSCRIPTION
  // ============================================
  void _setupWalletStream() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId != null) {
      _walletStream = Supabase.instance.client
          .from('fiat_wallets')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', currentUserId);
    } else {
      // Empty stream if no user
      _walletStream = const Stream.empty();
    }
  }

  // ============================================
  // 🔄 FETCH ALL BALANCES FROM FLUTTERWAVE & SUPABASE
  // ============================================
  Future<void> _fetchAllBalances() async {
    if (_isLoadingBalances) return;

    setState(() {
      _isLoadingBalances = true;
      _lastError = null;
    });

    try {
      // 1. Fetch NGN balance from Flutterwave API
      final flutterwaveBalance = await _fetchFlutterwaveBalance();

      // 2. Fetch current Supabase wallet data
      final supabaseData = await _fetchSupabaseWallet();

      // 3. Merge and update
      await _syncBalances(flutterwaveBalance, supabaseData);

      // 4. Update local state
      setState(() {
        _ngnBalance = flutterwaveBalance;
      });
    } catch (e) {
      setState(() {
        _lastError = 'Failed to fetch balances: $e';
      });
      debugPrint('Error fetching balances: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBalances = false;
        });
      }
    }
  }

  // ============================================
  // 🌐 FETCH FLUTTERWAVE BALANCE (NGN ONLY)
  // ============================================
  Future<double> _fetchFlutterwaveBalance() async {
    try {
      // Fetch wallet balances from Flutterwave
      final response = await http.get(
        Uri.parse('${FlutterwaveConfig.baseUrl}/wallet-balances'),
        headers: {
          'Authorization': 'Bearer ${FlutterwaveConfig.secretKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final walletData = data['data'] as List;

          // Find NGN wallet balance
          for (var wallet in walletData) {
            final currency = wallet['currency'] ?? '';
            if (currency == 'NGN') {
              final balance = (wallet['balance'] ?? 0.0).toDouble();
              final availableBalance = (wallet['available_balance'] ?? balance)
                  .toDouble();
              return availableBalance;
            }
          }
        }
      } else {
        debugPrint(
          'Flutterwave API error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to fetch Flutterwave balance');
      }
    } catch (e) {
      debugPrint('Error fetching Flutterwave balance: $e');
      rethrow;
    }

    return 0.0;
  }

  // ============================================
  // 📊 FETCH SUPABASE WALLET DATA
  // ============================================
  Future<Map<String, dynamic>?> _fetchSupabaseWallet() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return null;

      final response = await Supabase.instance.client
          .from('fiat_wallets')
          .select()
          .eq('user_id', currentUserId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching Supabase wallet: $e');
      return null;
    }
  }

  // ============================================
  /// 🔄 SYNC BALANCES TO SUPABASE
  // ============================================
  Future<void> _syncBalances(
    double flutterwaveBalance,
    Map<String, dynamic>? supabaseData,
  ) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'user_id': currentUserId,
        'ngn_balance': flutterwaveBalance,
        'last_synced_at': DateTime.now().toIso8601String(),
      };

      // Update or insert wallet data
      if (supabaseData != null) {
        // Update existing record
        await Supabase.instance.client
            .from('fiat_wallets')
            .update(updateData)
            .eq('user_id', currentUserId);
      } else {
        // Insert new record
        await Supabase.instance.client.from('fiat_wallets').insert(updateData);
      }

      // Create audit log for transparency
      await _createBalanceAuditLog(flutterwaveBalance);
    } catch (e) {
      debugPrint('Error syncing balances to Supabase: $e');
      rethrow;
    }
  }

  // ============================================
  // 📝 CREATE AUDIT LOG
  // ============================================
  Future<void> _createBalanceAuditLog(double ngnBalance) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      await Supabase.instance.client.from('balance_audit_logs').insert({
        'user_id': currentUserId,
        'ngn_balance': ngnBalance,
        'synced_at': DateTime.now().toIso8601String(),
        'source': 'flutterwave_sync',
      });
    } catch (e) {
      debugPrint('Error creating audit log: $e');
    }
  }

  // ============================================
  // 🔄 MANUAL REFRESH
  // ============================================
  Future<void> _manualRefresh() async {
    await _fetchAllBalances();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Balance refreshed successfully'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  // ============================================
  // 💰 HANDLE DEPOSIT WEBHOOK (NGN ONLY)
  // ============================================
  // This would be called by your webhook handler
  // when Flutterwave notifies you of a successful deposit
  static Future<void> handleDepositWebhook(Map<String, dynamic> payload) async {
    // Extract deposit details from webhook
    final amount = (payload['amount'] ?? 0.0).toDouble();
    final userId =
        payload['user_id']; // You'll need to map this from your system

    if (userId == null) return;

    // Update user's wallet balance using the stored procedure
    await Supabase.instance.client.rpc(
      'increment_balance',
      params: {'p_user_id': userId, 'p_amount': amount},
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeStateProvider);
    final isDarkPalette = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Layout configuration constants
    const headerTextColor = Color(0xFF6E7A8A);
    final tileBackground = isDarkPalette
        ? const Color(0xFF111622)
        : Colors.grey[200];
    final fallbackTitleColor = isDarkPalette ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkPalette ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'App Preferences',
          style: TextStyle(
            color: isDarkPalette ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(
              _isLoadingBalances ? Icons.sync : Icons.refresh_rounded,
              color: isDarkPalette ? Colors.white : Colors.black87,
            ),
            onPressed: _isLoadingBalances ? null : _manualRefresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // 📋 GENERAL SECTION
          _buildSectionHeader('GENERAL', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.language_rounded,
            title: 'Language',
            onTap: () => context.push('/language'),
          ),

          // ====================================================================
          // REAL-TIME CURRENCY HOLDINGS DROP-DOWN MENU (NGN ONLY)
          // ====================================================================
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: currentUserId != null
                  ? Supabase.instance.client
                        .from('fiat_wallets')
                        .stream(primaryKey: ['user_id'])
                        .eq('user_id', currentUserId)
                  : null,
              builder: (context, snapshot) {
                // Use local state values as fallback
                double ngn = _ngnBalance;

                // Update from snapshot if data is available
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final data = snapshot.data!.first;
                  ngn = (data['ngn_balance'] ?? _ngnBalance).toDouble();
                }

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tileBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoadingBalances
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF10B981),
                              ),
                            )
                          : const Icon(
                              Icons.monetization_on_outlined,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                    ),
                    title: Text(
                      'Currency Holdings Pool',
                      style: TextStyle(
                        color: fallbackTitleColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_lastError != null)
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDarkPalette
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ],
                    ),
                    children: [
                      // NGN Balance
                      _buildSubCurrencyRow(
                        context,
                        label: 'Nigerian Naira (NGN)',
                        value: '₦${ngn.toStringAsFixed(2)}',
                        icon: '🇳🇬',
                      ),
                      const SizedBox(height: 4),

                      // Last updated timestamp
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 52.0,
                          top: 8.0,
                          bottom: 4.0,
                          right: 4.0,
                        ),
                        child: Text(
                          'Last updated: ${DateTime.now().toLocal().toString().split('.').first}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkPalette
                                ? Colors.grey[500]
                                : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 🛡️ SECURITY SECTION
          _buildSectionHeader('SECURITY', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () => context.push('/settings/change-password'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.pin_outlined,
            title: 'Change Transaction PIN',
            onTap: () => context.push('/settings/change-pin'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Enable Biometrics',
            onTap: () => context.push('/biometric-setup'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.vibration_rounded,
            title: 'Enable 2FA',
            onTap: () => context.push('/settings/two-factor'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.devices_rounded,
            title: 'Device Management',
            onTap: () => context.push('/settings/devices'),
          ),
          const SizedBox(height: 16),

          // 🔔 NOTIFICATIONS SECTION
          _buildSectionHeader('NOTIFICATIONS', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            onTap: () => context.push('/settings/notifications-push'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.mail_outline_rounded,
            title: 'Email Notifications',
            onTap: () => context.push('/settings/notifications-email'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.sms_outlined,
            title: 'SMS Notifications',
            onTap: () => context.push('/settings/notifications-sms'),
          ),
          const SizedBox(height: 16),

          // 🔒 PRIVACY SECTION
          _buildSectionHeader('PRIVACY', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Data Sharing Preferences',
            onTap: () => context.push('/settings/privacy-sharing'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.download_for_offline_outlined,
            title: 'Download My Data',
            onTap: () => context.push('/settings/download-data'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            titleColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () => context.push('/settings/delete-account'),
          ),
          const SizedBox(height: 16),

          // 🎨 APPEARANCE SECTION
          _buildSectionHeader('APPEARANCE', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.wb_sunny_outlined,
            title: 'Light Mode',
            trailing: currentThemeMode == ThemeMode.light
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  )
                : null,
            onTap: () =>
                ref.read(themeStateProvider.notifier).state = ThemeMode.light,
          ),
          _buildMenuTile(
            context,
            icon: Icons.nightlight_round_outlined,
            title: 'Dark Mode',
            trailing: currentThemeMode == ThemeMode.dark
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  )
                : null,
            onTap: () =>
                ref.read(themeStateProvider.notifier).state = ThemeMode.dark,
          ),
          _buildMenuTile(
            context,
            icon: Icons.brightness_auto_outlined,
            title: 'System Default',
            trailing: currentThemeMode == ThemeMode.system
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  )
                : null,
            onTap: () =>
                ref.read(themeStateProvider.notifier).state = ThemeMode.system,
          ),
          const SizedBox(height: 16),

          // 💸 TRANSACTIONS SECTION
          _buildSectionHeader('TRANSACTIONS', headerTextColor),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Default Wallet',
            onTap: () => context.push('/settings/transactions/default-wallet'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.assignment_turned_in_outlined,
            title: 'Auto-save Beneficiaries',
            onTap: () => context.push('/settings/transactions/beneficiaries'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.speed_rounded,
            title: 'Transaction Limits',
            onTap: () => context.push('/transaction-settings'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 16.0, bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color iconColor = const Color(0xFF10B981),
    Color? titleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackTitleColor = isDark ? Colors.white : Colors.black87;
    final tileBackground = isDark ? const Color(0xFF111622) : Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tileBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? fallbackTitleColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing:
            trailing ??
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF374151),
              size: 13,
            ),
      ),
    );
  }

  Widget _buildSubCurrencyRow(
    BuildContext context, {
    required String label,
    required String value,
    String icon = '',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        left: 52.0,
        top: 4.0,
        bottom: 4.0,
        right: 4.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D111A) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF1A202E) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon.isNotEmpty) ...[
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
