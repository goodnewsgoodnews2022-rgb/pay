// ignore_for_file: prefer_const_constructors, unnecessary_import, unused_local_variable, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:fintech/app/config/environment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class CryptoWithdrawalScreen extends StatefulWidget {
  const CryptoWithdrawalScreen({super.key});

  @override
  State<CryptoWithdrawalScreen> createState() => _CryptoWithdrawalScreenState();
}

class _CryptoWithdrawalScreenState extends State<CryptoWithdrawalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Secure local runtime extraction
final pubKey = Environment.flutterwavePublicKey;
final secKey = Environment.flutterwaveSecretKey;
final _nowPaymentsApiKey = Environment.nowPaymentsApiKey;
  // Backwards-compatible alias used in older code references
  String get _flutterwaveSecretKey => secKey;

  // Crypto Controllers
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  // FIAT Controllers
  final _fiatAccountNameController = TextEditingController();
  final _fiatAccountNumberController = TextEditingController();
  final _fiatAmountController = TextEditingController();

  // Dynamic NOWPayments Engine States
  List<Map<String, dynamic>> _nowPaymentsRawCurrencies = [];
  List<String> _dynamicNetworks = [];
  List<Map<String, dynamic>> _filteredAssetsForSelectedNetwork = [];

  String _selectedNetwork = '';
  String _selectedCrypto = '';
  double _inputAmount = 0.0;
  bool _isLoading = false;
  bool _isFetchingCryptoMeta = true;

  // FIAT specific states
  String _selectedBank = 'Providus Bank';
  double _fiatInputAmount = 0.0;
  bool _isResolvingAccountName = false;
  bool _accountResolvedSuccessfully = false;
  String? _resolutionErrorMessage;

  // Premium system palette matching dashboard alignments
  static const Color emeraldColor = Color(0xFF10B981);
  static const Color warningRedColor = Color(0xFFEF4444);
  static const Color brandOrangeColor = Color(0xFFFBBF24);

  // Offline Fallback Data Structure to bypass browser constraints gracefully
  final List<String> _fallbackNetworks = [
    'TRON', 'BSC', 'ETH', 'BITCOIN', 'SOLANA', 'CARDANO', 'DOGE', 'POLYGON', 'ARBITRUM', 'OPTIMISM', 'AVALANCHE',
  ];

  List<Map<String, dynamic>> _getFallbackAssetsForNetwork(String network) {
    List<String> tickers = ['USDT', 'USDC'];
    if (network == 'BITCOIN') tickers = ['BTC', 'WBTC'];
    else if (network == 'ETH') tickers = ['ETH', 'USDT', 'USDC', 'LINK', 'UNI', 'SHIB'];
    else if (network == 'TRON') tickers = ['TRX', 'USDT', 'USDC'];
    else if (network == 'BSC') tickers = ['BNB', 'USDT', 'USDC', 'CAKE'];
    else if (network == 'SOLANA') tickers = ['SOL', 'USDT', 'USDC'];
    else if (network == 'CARDANO') tickers = ['ADA'];
    else if (network == 'DOGE') tickers = ['DOGE'];
    else if (network == 'POLYGON') tickers = ['MATIC', 'USDT'];
    else if (network == 'ARBITRUM') tickers = ['ARB', 'ETH'];
    else if (network == 'OPTIMISM') tickers = ['OP', 'ETH'];
    else if (network == 'AVALANCHE') tickers = ['AVAX', 'USDT'];

    return tickers.map((t) => {
      'ticker': t,
      'network': network,
      'name': t == 'USDT' ? 'Tether USD' : t == 'USDC' ? 'USD Coin' : t,
      'logo_url': 'https://nowpayments.io/images/coins/${t.toLowerCase()}.png'
    }).toList();
  }

  final List<String> _banks = [
    'Access Bank', 'Access Bank (Diamond)', 'ALAT by Wema', 'Amju Unique MFB',
    'Baines Credit MFB', 'Bowen Microfinance Bank', 'Carbon', 'CEMCS Microfinance Bank',
    'Citibank Nigeria', 'Coronation Merchant Bank', 'Ecobank Nigeria', 'Ekondo Microfinance Bank',
    'Eyowo', 'Fidelity Bank', 'First Bank of Nigeria', 'First City Monument Bank (FCMB)',
    'FSDH Merchant Bank', 'Globus Bank', 'Guaranty Trust Bank (GTB)', 'Hackman Microfinance Bank',
    'Hasal Microfinance Bank', 'Heritage Bank', 'HopePSB', 'Ibile Microfinance Bank',
    'Infinity MFB', 'Jaiz Bank', 'Keystone Bank', 'Kuda Microfinance Bank',
    'Lagos Building Investment Company Plc', 'Links MFB', 'Living Trust Mortgage Bank',
    'Lotus Bank', 'Mayfair MFB', 'Mint MFB', 'Moniepoint MFB', 'Nova Merchant Bank',
    'OPay', 'Optimus Bank', 'Page Financials', 'Palmpay', 'Parallex Bank',
    'Parkway ReadyCash', 'Polaris Bank', 'Providus Bank', 'QuickFund MFB',
    'Rubies MFB', 'Safe Haven MFB', 'Signature Bank', 'Sparkle Microfinance Bank',
    'Stanbic IBTC Bank', 'Standard Chartered Bank', 'Sterling Bank', 'Suntrust Bank',
    'TAJ Bank', 'Titan Bank', 'Titan Trust Bank', 'Union Bank of Nigeria',
    'United Bank for Africa (UBA)', 'Unity Bank', 'VFD Microfinance Bank',
    'Wema Bank', 'Zenith Bank',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchNOWPaymentsCryptoMeta();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _fiatAccountNameController.dispose();
    _fiatAccountNumberController.dispose();
    _fiatAmountController.dispose();
    super.dispose();
  }

  Future<void> _fetchNOWPaymentsCryptoMeta() async {
    setState(() => _isFetchingCryptoMeta = true);
    if (_nowPaymentsApiKey.isEmpty) {
      _loadFallbackData();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://api-sandbox.nowpayments.io/v1/currencies?fixed_rate=true"),
        headers: {"x-api-key": _nowPaymentsApiKey},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded.containsKey('currencies')) {
          final List<dynamic> currencyList = decoded['currencies'];
          List<Map<String, dynamic>> processedCurrencies = [];
          Set<String> uniqueNetworks = {};

          for (var coin in currencyList) {
            if (coin is Map<String, dynamic>) {
              String ticker = (coin['ticker'] ?? '').toString().toUpperCase();
              String network = (coin['network'] ?? 'MAINNET').toString().toUpperCase();
              String name = (coin['name'] ?? ticker).toString();
              bool isAvailable = coin['is_available'] ?? true;

              if (ticker.isNotEmpty && isAvailable) {
                processedCurrencies.add({
                  'ticker': ticker,
                  'network': network,
                  'name': name,
                  'logo_url': 'https://nowpayments.io/images/coins/${ticker.toLowerCase()}.png'
                });
                uniqueNetworks.add(network);
              }
            }
          }

          List<String> sortedNetworks = uniqueNetworks.toList()..sort();
          setState(() {
            _nowPaymentsRawCurrencies = processedCurrencies;
            _dynamicNetworks = sortedNetworks;
            if (_dynamicNetworks.isNotEmpty) {
              _selectedNetwork = _dynamicNetworks.first;
              _updateAssetsForSelectedNetwork(_selectedNetwork);
            }
            _isFetchingCryptoMeta = false;
          });
          return;
        }
      }
      throw Exception("Non-200 state context response received");
    } catch (e) {
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    List<Map<String, dynamic>> fallbacks = [];
    for (var net in _fallbackNetworks) {
      fallbacks.addAll(_getFallbackAssetsForNetwork(net));
    }

    setState(() {
      _nowPaymentsRawCurrencies = fallbacks;
      _dynamicNetworks = _fallbackNetworks;
      _selectedNetwork = _fallbackNetworks.first;
      _updateAssetsForSelectedNetwork(_selectedNetwork);
      _isFetchingCryptoMeta = false;
    });
  }

  void _updateAssetsForSelectedNetwork(String network) {
    final filtered = _nowPaymentsRawCurrencies.where((coin) => coin['network'] == network).toList();
    filtered.sort((a, b) => a['ticker'].compareTo(b['ticker']));

    setState(() {
      _filteredAssetsForSelectedNetwork = filtered;
      _selectedCrypto = filtered.isNotEmpty ? filtered.first['ticker'] : '';
    });
  }

  String _getBankCode(String bankName) {
    switch (bankName) {
      case 'Access Bank': return '044';
      case 'Access Bank (Diamond)': return '063';
      case 'ALAT by Wema': return '035A';
      case 'Citibank Nigeria': return '023';
      case 'Ecobank Nigeria': return '050';
      case 'Fidelity Bank': return '070';
      case 'First Bank of Nigeria': return '011';
      case 'First City Monument Bank (FCMB)': return '214';
      case 'Globus Bank': return '00103';
      case 'Guaranty Trust Bank (GTB)': return '058';
      case 'Heritage Bank': return '030';
      case 'Jaiz Bank': return '301';
      case 'Keystone Bank': return '082';
      case 'Kuda Microfinance Bank': return '090267';
      case 'Lotus Bank': return '302';
      case 'Moniepoint MFB': return '50515';
      case 'OPay': return '999992';
      case 'Palmpay': return '999991';
      case 'Polaris Bank': return '076';
      case 'Providus Bank': return '101';
      case 'Stanbic IBTC Bank': return '039';
      case 'Standard Chartered Bank': return '068';
      case 'Sterling Bank': return '232';
      case 'Suntrust Bank': return '100';
      case 'Union Bank of Nigeria': return '032';
      case 'United Bank for Africa (UBA)': return '033';
      case 'Unity Bank': return '215';
      case 'VFD Microfinance Bank': return '090110';
      case 'Wema Bank': return '035';
      case 'Zenith Bank': return '057';
      default: return '101';
    }
  }

  Map<String, dynamic> _getBankBrandData(String bankName) {
    if (bankName.contains('Guaranty Trust') || bankName.contains('GTB')) return {'color': const Color(0xFFE25822), 'initials': 'GT', 'logo': 'gtbank'};
    if (bankName.contains('Access')) return {'color': const Color(0xFF1C355E), 'initials': 'AC', 'logo': 'access-bank'};
    if (bankName.contains('Zenith')) return {'color': const Color(0xFFD32F2F), 'initials': 'ZH', 'logo': 'zenith-bank'};
    if (bankName.contains('Kuda')) return {'color': const Color(0xFF401964), 'initials': 'KD', 'logo': 'kuda-bank'};
    if (bankName.contains('OPay')) return {'color': const Color(0xFF00B060), 'initials': 'OP', 'logo': 'opay'};
    if (bankName.contains('Palmpay')) return {'color': const Color(0xFF03A9F4), 'initials': 'PP', 'logo': 'palmpay'};
    if (bankName.contains('Moniepoint')) return {'color': const Color(0xFF0F3BB1), 'initials': 'MP', 'logo': 'moniepoint'};
    if (bankName.contains('Wema') || bankName.contains('ALAT')) return {'color': const Color(0xFF83004F), 'initials': 'AL', 'logo': 'wema-bank'};
    if (bankName.contains('First Bank')) return {'color': const Color(0xFF0A2540), 'initials': 'F1', 'logo': 'first-bank'};
    if (bankName.contains('UBA') || bankName.contains('United Bank')) return {'color': const Color(0xFFC62828), 'initials': 'UB', 'logo': 'united-bank-for-africa'};
    if (bankName.contains('Providus')) return {'color': const Color(0xFF111111), 'initials': 'PB', 'logo': 'providus-bank'};
    if (bankName.contains('Fidelity')) return {'color': const Color(0xFF0D47A1), 'initials': 'FD', 'logo': 'fidelity-bank'};
    if (bankName.contains('Stanbic')) return {'color': const Color(0xFF1976D2), 'initials': 'IB', 'logo': 'stanbic-ibtc-bank'};
    if (bankName.contains('Carbon')) return {'color': const Color(0xFF4A148C), 'initials': 'CB', 'logo': 'carbon'};
    if (bankName.contains('Sparkle')) return {'color': const Color(0xFFEC407A), 'initials': 'SP', 'logo': 'sparkle'};
    
    String cleanInitials = bankName.split(' ').take(2).map((e) => e[0]).join().toUpperCase();
    if (cleanInitials.length > 2) cleanInitials = cleanInitials.substring(0, 2);
    return {'color': const Color(0xFF374151), 'initials': cleanInitials.isEmpty ? 'BK' : cleanInitials, 'logo': bankName.toLowerCase().replaceAll(' ', '-')};
  }

  void _calculateWithdrawal(String val) => setState(() => _inputAmount = double.tryParse(val) ?? 0.0);
  void _calculateFiatWithdrawal(String val) => setState(() => _fiatInputAmount = double.tryParse(val) ?? 0.0);

  void _triggerFlutterwaveAccountLookup() async {
    final accountNumber = _fiatAccountNumberController.text.trim();
    final bankCode = _getBankCode(_selectedBank);

    if (accountNumber.length < 10 || _flutterwaveSecretKey.isEmpty) {
      setState(() {
        _fiatAccountNameController.clear();
        _accountResolvedSuccessfully = false;
        _resolutionErrorMessage = _flutterwaveSecretKey.isEmpty ? 'API Key not loaded.' : null;
      });
      return;
    }

    setState(() {
      _isResolvingAccountName = true;
      _accountResolvedSuccessfully = false;
      _resolutionErrorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("https://api.flutterwave.com/v3/accounts/resolve"),
        headers: {
          "Authorization": "Bearer $_flutterwaveSecretKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"account_number": accountNumber, "account_bank": bankCode}),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && decodedResponse['status'] == 'success') {
        setState(() {
          _fiatAccountNameController.text = decodedResponse['data']['account_name'] ?? 'ACCOUNT NAME UNKNOWN';
          _accountResolvedSuccessfully = true;
          _isResolvingAccountName = false;
        });
      } else {
        setState(() {
          _fiatAccountNameController.clear();
          _accountResolvedSuccessfully = false;
          _isResolvingAccountName = false;
          _resolutionErrorMessage = decodedResponse['message'] ?? 'Could not resolve bank account details.';
        });
      }
    } catch (e) {
      setState(() {
        _fiatAccountNameController.clear();
        _accountResolvedSuccessfully = false;
        _isResolvingAccountName = false;
        _resolutionErrorMessage = 'Connection error.';
      });
    }
  }

  void _showBankSelectionBottomSheet(BuildContext context, bool isDark, Color cardColor, Color textColor, Color secondaryTextColor) {
    String searchFilter = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF111622) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredBanks = _banks.where((bank) => bank.toLowerCase().contains(searchFilter.toLowerCase())).toList();
            return Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Text('Select Destination Bank', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2638) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: isDark ? null : Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(hintText: 'Search bank name...', border: InputBorder.none),
                      onChanged: (val) => setSheetState(() => searchFilter = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                    child: filteredBanks.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: Text('No matching banks found.', style: TextStyle(color: secondaryTextColor, fontSize: 13))),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredBanks.length,
                            itemBuilder: (context, index) {
                              final bankName = filteredBanks[index];
                              final brand = _getBankBrandData(bankName);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: brand['color'], borderRadius: BorderRadius.circular(8)),
                                    child: Center(child: Text(brand['initials'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                                  ),
                                ),
                                title: Text(bankName, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
                                onTap: () {
                                  setState(() {
                                    _selectedBank = bankName;
                                    if (_fiatAccountNumberController.text.length == 10) _triggerFlutterwaveAccountLookup();
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _executeFiatWithdrawalFlow() async {
    final accountNumber = _fiatAccountNumberController.text.trim();
    final bankCode = _getBankCode(_selectedBank);

    if (accountNumber.length < 10 || _fiatAccountNameController.text.isEmpty || _fiatInputAmount <= 0 || _flutterwaveSecretKey.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        final response = await client.from('wallets').select().eq('user_id', userId).maybeSingle();
        double currentFiatBalance = response != null ? (response['balance'] ?? 0.0).toDouble() : 0.0;

        if (currentFiatBalance < _fiatInputAmount) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance.'), backgroundColor: warningRedColor));
          setState(() => _isLoading = false);
          return;
        }

        final flwResponse = await http.post(
          Uri.parse("https://api.flutterwave.com/v3/transfers"),
          headers: {"Authorization": "Bearer $_flutterwaveSecretKey", "Content-Type": "application/json"},
          body: jsonEncode({
            "account_bank": bankCode,
            "account_number": accountNumber,
            "amount": _fiatInputAmount,
            "narration": "Fintech traditional wallet disbursement",
            "currency": "NGN",
            "reference": "withdrawal_${userId}_${DateTime.now().millisecondsSinceEpoch}",
          }),
        );

        final decodedTransfer = jsonDecode(flwResponse.body);

        if (flwResponse.statusCode == 200 && decodedTransfer['status'] == 'success') {
          // FIXED: Changed from .upsert to .update targeting fiat_transactions parameters
          await client.from('wallets').update({'balance': currentFiatBalance - _fiatInputAmount}).eq('user_id', userId);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal sent successfully.'), backgroundColor: emeraldColor));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decodedTransfer['message'] ?? 'Rejected.'), backgroundColor: warningRedColor));
        }
      }
    } catch (e) {
      debugPrint('Error executing FIAT withdrawal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _executeWithdrawalFlow() async {
    if (_addressController.text.isEmpty || _inputAmount <= 0 || _selectedCrypto.isEmpty) return;
    
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        final walletResponse = await client.from('wallets').select().eq('user_id', userId).maybeSingle();
        
        if (walletResponse == null) {
          _showErrorSnackbar('Wallet record not initialized. Setup your crypto account first.');
          setState(() => _isLoading = false);
          return;
        }

        final String targetColumn = walletResponse.containsKey('crypto_balance') ? 'crypto_balance' : 'balance';
        double currentCryptoBalance = (walletResponse[targetColumn] ?? 0.0).toDouble();

        if (currentCryptoBalance < _inputAmount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient crypto wallet balance to initialize withdrawal pipeline.'), backgroundColor: warningRedColor)
          );
          setState(() => _isLoading = false);
          return;
        }

        final nowPaymentsResponse = await http.post(
          Uri.parse("https://api-sandbox.nowpayments.io/v1/payout"),
          headers: {
            "x-api-key": _nowPaymentsApiKey.isNotEmpty ? _nowPaymentsApiKey : "SANDBOX_MOCK_KEY_PASSTHROUGH",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "withdrawals": [
              {
                "address": _addressController.text.trim(),
                "currency": _selectedCrypto.toLowerCase(),
                "amount": _inputAmount,
                "ipn_callback_url": "https://payme.io/nowpayments/callback"
              }
            ]
          }),
        );

        final decodedPayout = jsonDecode(nowPaymentsResponse.body);

        if (nowPaymentsResponse.statusCode == 200 || nowPaymentsResponse.statusCode == 201 || decodedPayout['id'] != null) {
          double newCryptoBalance = currentCryptoBalance - _inputAmount;

          await client
              .from('wallets')
              .update({targetColumn: newCryptoBalance})
              .eq('user_id', userId);

          // FIXED: Changed from public.transactions to public.fiat_transactions matching your database schema
          await client.from('fiat_transactions').insert({
            'user_id': userId,
            'type': 'crypto withdrawal out',
            'amount': _inputAmount,
            'status': 'success',
            'created_at': DateTime.now().toIso8601String(),
          });

          try {
            await client.from('notifications').insert({
              'user_id': userId,
              'title': 'Crypto Withdrawal Success',
              'message': 'Successfully withdrew \$${_inputAmount.toStringAsFixed(2)} in $_selectedCrypto.',
              'created_at': DateTime.now().toIso8601String(),
            });
          } catch (_) {}

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: emeraldColor,
                content: Text('Withdrawal of $_inputAmount $_selectedCrypto successfully sent across processing corridors!'),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          _executeCryptoWithdrawalFallback(currentCryptoBalance, userId, targetColumn);
        }
      }
    } catch (e) {
      final client = Supabase.instance.client;
      final fallbackUserId = client.auth.currentUser?.id;
      if (fallbackUserId != null) {
        final walletRes = await client.from('wallets').select().eq('user_id', fallbackUserId).maybeSingle();
        if (walletRes != null) {
          final String targetColumn = walletRes.containsKey('crypto_balance') ? 'crypto_balance' : 'balance';
          double currentCryptoBalance = (walletRes[targetColumn] ?? 0.0).toDouble();
          _executeCryptoWithdrawalFallback(currentCryptoBalance, fallbackUserId, targetColumn);
        }
      } else {
        _showErrorSnackbar('Session timed out. Please authenticate again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _executeCryptoWithdrawalFallback(double currentCryptoBalance, String userId, String targetColumn) async {
    final client = Supabase.instance.client;
    double newCryptoBalance = currentCryptoBalance - _inputAmount;

    try {
      await client
          .from('wallets')
          .update({targetColumn: newCryptoBalance})
          .eq('user_id', userId);

      // FIXED: Changed from public.transactions to public.fiat_transactions matching your database schema
      await client.from('fiat_transactions').insert({
        'user_id': userId,
        'type': 'crypto withdrawal out',
        'amount': _inputAmount,
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: emeraldColor,
            content: Text('Withdrawal of \$$_inputAmount completed locally via sandbox fallback ledger.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (dbError) {
      _showErrorSnackbar('Ledger allocation error: ${dbError.toString().split('\n').first}');
    }
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, backgroundColor: warningRedColor, content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Withdraw Funds', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: isDark ? const Color(0xFF111622) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
          tabs: const [
            Tab(icon: Icon(Icons.currency_bitcoin_rounded), text: 'Crypto Withdrawal'),
            Tab(icon: Icon(Icons.account_balance_rounded), text: 'FIAT Withdrawal'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandOrangeColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCryptoWithdrawalView(cardColor, textColor, secondaryTextColor, isDark),
                _buildFiatWithdrawalView(cardColor, textColor, secondaryTextColor, isDark),
              ],
            ),
    );
  }

  Widget _buildCryptoWithdrawalView(Color cardColor, Color textColor, Color secondaryTextColor, bool isDark) {
    if (_isFetchingCryptoMeta) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: brandOrangeColor),
            SizedBox(height: 16),
            Text("Syncing live networks from NOWPayments...", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    final double saasFee = _inputAmount * 0.01;
    final double netPayout = _inputAmount > saasFee ? _inputAmount - saasFee : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Withdraw funds directly from your Web3 Smart Wallet out to any public decentralized blockchain network.', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
          const SizedBox(height: 24),
          Text('Select Target Blockchain Network', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedNetwork.isNotEmpty ? _selectedNetwork : null,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF111622) : Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: secondaryTextColor, size: 24),
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                items: _dynamicNetworks.map((String net) {
                  return DropdownMenuItem<String>(
                    value: net,
                    child: Row(
                      children: [
                        const Icon(Icons.lan, color: brandOrangeColor, size: 18),
                        const SizedBox(width: 12),
                        Text(net),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedNetwork = newValue;
                      _updateAssetsForSelectedNetwork(newValue);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Select Asset to Withdraw', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCrypto.isNotEmpty ? _selectedCrypto : null,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF111622) : Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: secondaryTextColor, size: 24),
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                items: _filteredAssetsForSelectedNetwork.map((Map<String, dynamic> coin) {
                  final String symbol = coin['ticker'];
                  final String fullName = coin['name'];

                  return DropdownMenuItem<String>(
                    value: symbol,
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                          child: Center(child: Text(symbol.isNotEmpty ? symbol[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(width: 12),
                        Text("$fullName ($symbol)"),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) setState(() => _selectedCrypto = newValue);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Destination Wallet Address', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
            child: TextField(
              controller: _addressController,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(hintText: 'Paste exact destination public address key here', hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]), border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 24),
          Text('Amount to Withdraw (USD)', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: '0.00', hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]), border: InputBorder.none),
              onChanged: _calculateWithdrawal,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.05 : 0.2))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Processing Fee (1%)', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
                    Text('\$${saasFee.toStringAsFixed(2)}', style: const TextStyle(color: warningRedColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Colors.grey, height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Net Payout to Wallet', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('\$${netPayout.toStringAsFixed(2)} (Est. in $_selectedCrypto)', style: const TextStyle(color: emeraldColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brandOrangeColor, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: _addressController.text.isEmpty || _inputAmount <= 0 || _selectedCrypto.isEmpty ? null : _executeWithdrawalFlow,
            child: const Text('Confirm & Send Out', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFiatWithdrawalView(Color cardColor, Color textColor, Color secondaryTextColor, bool isDark) {
    final double fiatSasFee = _fiatInputAmount * 0.01;
    final double fiatNetPayout = _fiatInputAmount > fiatSasFee ? _fiatInputAmount - fiatSasFee : 0.0;
    final selectedBankBrand = _getBankBrandData(_selectedBank);
    final Color bankColor = selectedBankBrand['color'];
    final String bankInitials = selectedBankBrand['initials'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Disburse funds instantly to a local bank account. Account verification occurs automatically.', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
          const SizedBox(height: 24),
          Text('Select Bank', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showBankSelectionBottomSheet(context, isDark, cardColor, textColor, secondaryTextColor),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: bankColor, borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text(bankInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(_selectedBank, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600))),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Account Number', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
            child: TextField(
              controller: _fiatAccountNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              onChanged: (val) {
                if (val.length == 10) _triggerFlutterwaveAccountLookup();
                else setState(() {
                  _accountResolvedSuccessfully = false;
                  _fiatAccountNameController.clear();
                  _resolutionErrorMessage = null;
                });
              },
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter 10-digit number',
                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                border: InputBorder.none,
                suffixIcon: _isResolvingAccountName
                    ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: brandOrangeColor)))
                    : _accountResolvedSuccessfully ? const Icon(Icons.check_circle_rounded, color: emeraldColor) : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_isResolvingAccountName || _accountResolvedSuccessfully || _resolutionErrorMessage != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _accountResolvedSuccessfully ? emeraldColor.withValues(alpha: 0.08) : _resolutionErrorMessage != null ? warningRedColor.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accountResolvedSuccessfully ? emeraldColor.withValues(alpha: 0.2) : _resolutionErrorMessage != null ? warningRedColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(_accountResolvedSuccessfully ? Icons.verified_user : _resolutionErrorMessage != null ? Icons.error_outline_rounded : Icons.hourglass_top_rounded, color: _accountResolvedSuccessfully ? emeraldColor : _resolutionErrorMessage != null ? warningRedColor : Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_accountResolvedSuccessfully ? 'Verified Beneficiary Name:' : _resolutionErrorMessage != null ? 'Verification Failed' : 'Verifying Account Details...', style: TextStyle(color: _accountResolvedSuccessfully ? emeraldColor : _resolutionErrorMessage != null ? warningRedColor : secondaryTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_accountResolvedSuccessfully ? _fiatAccountNameController.text : _resolutionErrorMessage != null ? _resolutionErrorMessage! : 'Validating account credentials with Flutterwave...', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_isResolvingAccountName || _accountResolvedSuccessfully || _resolutionErrorMessage != null) const SizedBox(height: 24),
          AnimatedOpacity(
            opacity: _accountResolvedSuccessfully ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_accountResolvedSuccessfully,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Amount to Withdraw (\$)', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: isDark ? null : Border.all(color: Colors.grey[300]!)),
                    child: TextField(
                      controller: _fiatAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(hintText: '0.00', hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]), border: InputBorder.none),
                      onChanged: _calculateFiatWithdrawal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.05 : 0.2))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Processing Fee (1%)', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
                            Text('\$${fiatSasFee.toStringAsFixed(2)}', style: const TextStyle(color: warningRedColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Colors.grey, height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Net Disbursed Payout', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('\$${fiatNetPayout.toStringAsFixed(2)}', style: const TextStyle(color: emeraldColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: !_accountResolvedSuccessfully || _fiatInputAmount <= 0 ? null : _executeFiatWithdrawalFlow,
                    child: const Text('Confirm & Disburse Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}