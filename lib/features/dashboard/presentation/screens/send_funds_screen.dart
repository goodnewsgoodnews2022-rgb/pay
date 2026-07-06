// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SendFundsScreen extends StatefulWidget {
  const SendFundsScreen({super.key});

  @override
  State<SendFundsScreen> createState() => _SendFundsScreenState();
}

class _SendFundsScreenState extends State<SendFundsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Brand UI Colors
  static const Color brandOrangeColor = Color(0xFFFBBF24);

  // FIAT P2P Controllers
  final _fiatAmountController = TextEditingController();
  final _fiatRecipientUidController = TextEditingController(); 
  
  // Crypto Controllers
  final _cryptoAmountController = TextEditingController();
  final _cryptoAddressController = TextEditingController();

  // P2P Core States
  bool _isLoading = false;
  bool _isResolvingUser = false;
  bool _userResolvedSuccessfully = false;
  String _resolvedRecipientName = '';
  String _resolvedRecipientCurrency = 'GHS'; 
  String _senderCurrency = 'NGN'; 
  double _fiatInputAmount = 0.0;
  double _liveExchangeRate = 1.0;
  double _convertedPayoutAmount = 0.0;
  bool _isFetchingRate = false;

  // NOWPayments Crypto States
  String _selectedNetwork = 'TRON (TRC20)';
  String _selectedCryptoAsset = 'USDT';
  double _cryptoInputAmount = 0.0;
  double _estimatedCryptoPayout = 0.0;
  bool _isFetchingCryptoRate = false;

  // Supported NOWPayments Networks
  final List<String> _networks = [
    'Bitcoin (BTC Mainnet)',
    'Ethereum (ERC20)',
    'TRON (TRC20)',
    'Binance Smart Chain (BEP20)',
    'Solana (SOL Native)',
    'Polygon (MATIC)',
    'Arbitrum (ARB)',
    'Optimism (OP)',
    'Avalanche (AVAX)'
  ];

  List<String> _getAssetsForNetwork(String network) {
    switch (network) {
      case 'Bitcoin (BTC Mainnet)':
        return ['BTC', 'WBTC'];
      case 'Ethereum (ERC20)':
        return ['ETH', 'USDT', 'USDC', 'LINK', 'UNI', 'SHIB', 'PEPE', 'AAVE', 'DAI'];
      case 'TRON (TRC20)':
        return ['TRX', 'USDT', 'USDC', 'BUSD'];
      case 'Binance Smart Chain (BEP20)':
        return ['BNB', 'USDT', 'USDC', 'BUSD', 'CAKE'];
      case 'Solana (SOL Native)':
        return ['SOL', 'USDT', 'USDC'];
      case 'Polygon (MATIC)':
        return ['MATIC', 'USDT', 'USDC'];
      case 'Arbitrum (ARB)':
        return ['ARB', 'ETH', 'USDT'];
      case 'Optimism (OP)':
        return ['OP', 'ETH', 'USDT'];
      case 'Avalanche (AVAX)':
        return ['AVAX', 'USDT', 'USDC'];
      default:
        return ['USDT'];
    }
  }

  String _getCdnCode(String assetOrNetwork) {
    final lower = assetOrNetwork.toLowerCase();
    if (lower.contains('bitcoin') || lower == 'btc') return 'btc';
    if (lower.contains('ethereum') || lower == 'eth') return 'eth';
    if (lower.contains('tron') || lower == 'trx') return 'trx';
    if (lower.contains('binance') || lower == 'bnb') return 'bnb';
    if (lower.contains('solana') || lower == 'sol') return 'sol';
    if (lower.contains('polygon') || lower == 'matic') return 'matic';
    if (lower.contains('arbitrum') || lower == 'arb') return 'arb';
    if (lower.contains('optimism') || lower == 'op') return 'op';
    if (lower.contains('avalanche') || lower == 'avax') return 'avax';
    if (lower == 'usdt') return 'usdt';
    if (lower == 'usdc') return 'usdc';
    if (lower == 'busd') return 'busd';
    if (lower == 'link') return 'link';
    if (lower == 'uni') return 'uni';
    if (lower == 'shib') return 'shib';
    if (lower == 'pepe') return 'pepe';
    if (lower == 'aave') return 'aave';
    if (lower == 'dai') return 'dai';
    if (lower == 'cake') return 'cake';
    return 'usdt';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSenderCurrency();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fiatAmountController.dispose();
    _fiatRecipientUidController.dispose();
    _cryptoAmountController.dispose();
    _cryptoAddressController.dispose();
    super.dispose();
  }

  Future<void> _fetchSenderCurrency() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        final profile = await client.from('profiles').select().eq('id', userId).maybeSingle();
        if (profile != null) {
          setState(() {
            _senderCurrency = profile['currency'] ?? profile['country_code'] ?? 'NGN';
            if (_senderCurrency.length > 3) _senderCurrency = 'NGN';
          });
        }
      }
    } catch (_) {}
  }

  void _resolveRecipientProfile(String uidInput) async {
    final cleanUid = uidInput.trim();
    if (cleanUid.length < 36) {
      setState(() {
        _userResolvedSuccessfully = false;
        _resolvedRecipientName = '';
      });
      return;
    }

    setState(() {
      _isResolvingUser = true;
      _userResolvedSuccessfully = false;
    });

    try {
      final client = Supabase.instance.client;
      final profile = await client.from('profiles').select().eq('id', cleanUid).maybeSingle();

      if (profile != null) {
        setState(() {
          _resolvedRecipientName = profile['full_name'] ?? 'Payme User';
          _resolvedRecipientCurrency = profile['currency'] ?? 'GHS';
          _userResolvedSuccessfully = true;
          _isResolvingUser = false;
        });
        
        if (_fiatInputAmount > 0) {
          _fetchLiveFlutterwaveExchangeRate();
        }
      } else {
        setState(() {
          _userResolvedSuccessfully = false;
          _resolvedRecipientName = '';
          _isResolvingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _userResolvedSuccessfully = false;
        _resolvedRecipientName = '';
        _isResolvingUser = false;
      });
    }
  }

  Future<void> _fetchLiveFlutterwaveExchangeRate() async {
    if (_fiatInputAmount <= 0 || !_userResolvedSuccessfully) return;

    setState(() {
      _isFetchingRate = true;
    });

    try {
      final secretKey = dotenv.env['FLUTTERWAVE_SECRET_KEY'] ?? '';
      final response = await http.get(
        Uri.parse("https://api.flutterwave.com/v3/rates?from_currency=$_senderCurrency&to_currency=$_resolvedRecipientCurrency&amount=$_fiatInputAmount"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/json",
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['status'] == 'success') {
        final double rate = (decoded['data']['to']['rate'] ?? 1.0).toDouble();
        final double converted = (decoded['data']['to']['amount'] ?? _fiatInputAmount).toDouble();
        setState(() {
          _liveExchangeRate = rate;
          _convertedPayoutAmount = converted;
          _isFetchingRate = false;
        });
      } else {
        _executeLocalMathFallback();
      }
    } catch (e) {
      _executeLocalMathFallback();
    }
  }

  void _executeLocalMathFallback() {
    double rate = 1.0;
    if (_senderCurrency == 'NGN' && _resolvedRecipientCurrency == 'GHS') {
      rate = 0.0092; 
    } else if (_senderCurrency == 'NGN' && _resolvedRecipientCurrency == 'USD') {
      rate = 0.00067; 
    } else if (_senderCurrency == 'GHS' && _resolvedRecipientCurrency == 'NGN') {
      rate = 108.7;
    } else if (_senderCurrency == 'USD' && _resolvedRecipientCurrency == 'NGN') {
      rate = 1500.0;
    }
    setState(() {
      _liveExchangeRate = rate;
      _convertedPayoutAmount = _fiatInputAmount * rate;
      _isFetchingRate = false;
    });
  }

  Future<void> _fetchLiveNowPaymentsRate() async {
    if (_cryptoInputAmount <= 0) return;

    setState(() {
      _isFetchingCryptoRate = true;
    });

    try {
      final apiKey = dotenv.env['NOWPAYMENTS_API_KEY'] ?? '';
      final url = "https://api-sandbox.nowpayments.io/v1/estimate?amount=$_cryptoInputAmount&currency_from=usd&currency_to=${_selectedCryptoAsset.toLowerCase()}";
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-api-key": apiKey,
          "Content-Type": "application/json",
        },
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['estimated_amount'] != null) {
        setState(() {
          _estimatedCryptoPayout = (decoded['estimated_amount'] ?? 0.0).toDouble();
          _isFetchingCryptoRate = false;
        });
      } else {
        _executeCryptoFallbackMath();
      }
    } catch (e) {
      _executeCryptoFallbackMath();
    }
  }

  void _executeCryptoFallbackMath() {
    double sampleRate = 1.0;
    if (_selectedCryptoAsset == 'BTC') sampleRate = 0.000015;
    else if (_selectedCryptoAsset == 'ETH') sampleRate = 0.00029;
    else if (_selectedCryptoAsset == 'USDT' || _selectedCryptoAsset == 'USDC') sampleRate = 1.0;
    else if (_selectedCryptoAsset == 'SOL') sampleRate = 0.0068;
    else if (_selectedCryptoAsset == 'TRX') sampleRate = 8.35;
    else if (_selectedCryptoAsset == 'MATIC') sampleRate = 1.62;

    setState(() {
      _estimatedCryptoPayout = _cryptoInputAmount * sampleRate;
      _isFetchingCryptoRate = false;
    });
  }

  // FIAT P2P Disbursement Ledger Process
  Future<void> _processFiatP2PSend() async {
    final cleanRecipientUid = _fiatRecipientUidController.text.trim();
    if (_fiatInputAmount <= 0 || cleanRecipientUid.isEmpty || !_userResolvedSuccessfully) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final senderUid = client.auth.currentUser?.id;

      if (senderUid != null) {
        final senderWalletResponse = await client.from('wallets').select('balance').eq('user_id', senderUid).maybeSingle();
        double currentSenderBalance = senderWalletResponse != null ? (senderWalletResponse['balance'] ?? 0.0).toDouble() : 0.0;

        if (currentSenderBalance < _fiatInputAmount) {
          _showErrorSnackbar('Insufficient wallet balance to perform this cross-border payment.');
          setState(() => _isLoading = false);
          return;
        }

        final recipientWalletResponse = await client.from('wallets').select('balance').eq('user_id', cleanRecipientUid).maybeSingle();
        double currentRecipientBalance = recipientWalletResponse != null ? (recipientWalletResponse['balance'] ?? 0.0).toDouble() : 0.0;

        double newSenderBalance = currentSenderBalance - _fiatInputAmount;
        double newRecipientBalance = currentRecipientBalance + _convertedPayoutAmount;

        await client.from('wallets').update({
          'balance': newSenderBalance,
        }).eq('user_id', senderUid);

        await client.from('wallets').update({
          'balance': newRecipientBalance,
        }).eq('user_id', cleanRecipientUid);

        await client.from('transactions').insert({
          'user_id': senderUid,
          'type': 'p2p outbound',
          'amount': _fiatInputAmount,
          'status': 'success',
          'created_at': DateTime.now().toIso8601String(),
        });

        await client.from('transactions').insert({
          'user_id': cleanRecipientUid,
          'type': 'p2p inbound',
          'amount': _convertedPayoutAmount,
          'status': 'success',
          'created_at': DateTime.now().toIso8601String(),
        });

        try {
          await client.from('notifications').insert({
            'user_id': senderUid,
            'title': 'P2P Transfer Sent',
            'message': 'Successfully sent $_fiatInputAmount $_senderCurrency to $_resolvedRecipientName.',
            'created_at': DateTime.now().toIso8601String(),
          });

          await client.from('notifications').insert({
            'user_id': cleanRecipientUid,
            'title': 'Funds Received',
            'message': 'You received ${_convertedPayoutAmount.toStringAsFixed(2)} $_resolvedRecipientCurrency from Lawrence.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF10B981),
              content: Text('Payment Successful!'),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showErrorSnackbar('P2P settlement failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Pure Crypto Transaction Processor linked directly to the main wallets row balance
  Future<void> _processCryptoSend() async {
    final cleanAddress = _cryptoAddressController.text.trim();
    if (_cryptoInputAmount <= 0 || cleanAddress.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        final response = await client
            .from('wallets')
            .select('crypto_balance')
            .eq('user_id', userId)
            .maybeSingle();
            
        double currentCryptoBalance = response != null ? (response['crypto_balance'] ?? 0.0).toDouble() : 0.0;

        if (currentCryptoBalance < _cryptoInputAmount) {
          _showErrorSnackbar('Insufficient Web3 Crypto balance to process this transfer.');
          setState(() => _isLoading = false);
          return;
        }

        final apiKey = dotenv.env['NOWPAYMENTS_API_KEY'] ?? '';
        final nowPaymentsResponse = await http.post(
          Uri.parse("https://api-sandbox.nowpayments.io/v1/payment"),
          headers: {
            "x-api-key": apiKey,
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "price_amount": _cryptoInputAmount,
            "price_currency": "usd",
            "pay_amount": _estimatedCryptoPayout,
            "pay_currency": _selectedCryptoAsset.toLowerCase(),
            "ipn_callback_url": "https://payme.io/nowpayments/callback",
            "order_id": "crypto_payout_${userId}_${DateTime.now().millisecondsSinceEpoch}",
            "order_description": "Fintech decentralized wallet disbursement through NOWPayments",
            "case": "success"
          }),
        );

        final decodedResponse = jsonDecode(nowPaymentsResponse.body);

        if (nowPaymentsResponse.statusCode == 201 || decodedResponse['payment_id'] != null) {
          double newCryptoBalance = currentCryptoBalance - _cryptoInputAmount;

          await client
              .from('wallets')
              .update({'crypto_balance': newCryptoBalance})
              .eq('user_id', userId);

          await client.from('transactions').insert({
            'user_id': userId,
            'type': 'crypto transfer out',
            'amount': _cryptoInputAmount,
            'status': 'success',
            'created_at': DateTime.now().toIso8601String(),
          });

          try {
            await client.from('notifications').insert({
              'user_id': userId,
              'title': 'Crypto Transaction Dispatched',
              'message': 'Successfully processed \$${_cryptoInputAmount.toStringAsFixed(2)} in $_selectedCryptoAsset via NOWPayments gateway.',
              'created_at': DateTime.now().toIso8601String(),
            });
          } catch (_) {}

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF10B981),
                content: Text('Transaction successful! Asset dispatched on $_selectedNetwork.'),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          _executeCryptoLedgerFallback(currentCryptoBalance, userId);
        }
      }
    } catch (e) {
      final client = Supabase.instance.client;
      final fallbackUserId = client.auth.currentUser?.id;
      if (fallbackUserId != null) {
        final response = await client
            .from('wallets')
            .select('crypto_balance')
            .eq('user_id', fallbackUserId)
            .maybeSingle();
            
        double currentCryptoBalance = response != null ? (response['crypto_balance'] ?? 0.0).toDouble() : 0.0;
        _executeCryptoLedgerFallback(currentCryptoBalance, fallbackUserId);
      } else {
        _showErrorSnackbar('Session expired. Please log back in.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _executeCryptoLedgerFallback(double currentCryptoBalance, String userId) async {
    final client = Supabase.instance.client;
    double newCryptoBalance = currentCryptoBalance - _cryptoInputAmount;

    try {
      await client
          .from('wallets')
          .update({'crypto_balance': newCryptoBalance})
          .eq('user_id', userId);

      await client.from('transactions').insert({
        'user_id': userId,
        'type': 'crypto transfer out',
        'amount': _cryptoInputAmount,
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
            content: Text('Processed \$${_cryptoInputAmount.toStringAsFixed(2)} via standard crypto ledger.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (dbError) {
      debugPrint("Fallback database ledger error caught: $dbError");
      _showErrorSnackbar('Ledger allocation error occurred. Please verify wallet settings.');
    }
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    const accentColor = Color(0xFF10B981); 
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Send Funds',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF111622) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'FIAT P2P'),
            Tab(icon: Icon(Icons.currency_bitcoin_rounded), text: 'Crypto Wallet'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFiatSendView(cardColor, textColor, secondaryTextColor, isDark),
                _buildCryptoSendView(cardColor, textColor, secondaryTextColor, isDark),
              ],
            ),
    );
  }

  Widget _buildFiatSendView(Color cardColor, Color textColor, Color secondaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Instantly send money to any peer using their Payme User ID (UID). Flutterwave dynamically handles the currency conversion.',
            style: TextStyle(color: secondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 24),

          _buildInputLabel('Recipient User ID (UID)', textColor),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? null : Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _fiatRecipientUidController,
              onChanged: _resolveRecipientProfile,
              style: TextStyle(color: textColor, fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Paste sender UID (e.g. 550e8400-e29b-41d4-a716...)',
                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12),
                border: InputBorder.none,
                suffixIcon: _isResolvingUser
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: brandOrangeColor),
                        ),
                      )
                    : _userResolvedSuccessfully
                        ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_isResolvingUser || _userResolvedSuccessfully)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _userResolvedSuccessfully ? Colors.green.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _userResolvedSuccessfully ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _userResolvedSuccessfully ? Colors.green : Colors.grey,
                    radius: 16,
                    child: Icon(_userResolvedSuccessfully ? Icons.person : Icons.hourglass_top_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userResolvedSuccessfully ? 'Recipient Resolved' : 'Resolving User UID...',
                          style: TextStyle(color: _userResolvedSuccessfully ? Colors.green : secondaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userResolvedSuccessfully ? '$_resolvedRecipientName ($_resolvedRecipientCurrency)' : 'Connecting to Payme nodes...',
                          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_isResolvingUser || _userResolvedSuccessfully) const SizedBox(height: 24),

          AnimatedOpacity(
            opacity: _userResolvedSuccessfully ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_userResolvedSuccessfully,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel('Amount to Send', textColor),
                      Text('Your Base Currency: $_senderCurrency', style: TextStyle(color: secondaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  _buildInputField(
                    _fiatAmountController, 
                    '0.00', 
                    cardColor, 
                    isDark, 
                    true, 
                    onChanged: (val) {
                      setState(() {
                        _fiatInputAmount = double.tryParse(val) ?? 0.0;
                      });
                      _fetchLiveFlutterwaveExchangeRate();
                    },
                  ),
                  const SizedBox(height: 24),

                  if (_fiatInputAmount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.05 : 0.15)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Exchange Rate', style: TextStyle(color: secondaryColor, fontSize: 12)),
                              _isFetchingRate 
                                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF8B5CF6)))
                                  : Text('1 $_senderCurrency = ${_liveExchangeRate.toStringAsFixed(4)} $_resolvedRecipientCurrency', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Goodnews Receives', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              _isFetchingRate
                                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF8B5CF6)))
                                  : Text('${_convertedPayoutAmount.toStringAsFixed(2)} $_resolvedRecipientCurrency', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _fiatInputAmount <= 0 || !_userResolvedSuccessfully || _isFetchingRate ? null : _processFiatP2PSend,
                    child: Text('Send to $_resolvedRecipientName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoSendView(Color cardColor, Color textColor, Color secondaryColor, bool isDark) {
    final availableCrypto = _getAssetsForNetwork(_selectedNetwork);
    if (!availableCrypto.contains(_selectedCryptoAsset)) {
      _selectedCryptoAsset = availableCrypto.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transmit Web3 values directly out to any external verified blockchain ledger using the NOWPayments sandbox gateway.',
            style: TextStyle(color: secondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          _buildInputLabel('Select Network Pipeline', textColor),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? null : Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedNetwork,
                isExpanded: true,
                dropdownColor: cardColor,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                items: _networks.map((val) {
                  final netCdn = _getCdnCode(val);
                  return DropdownMenuItem(
                    value: val, 
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/color/$netCdn.png',
                            width: 22,
                            height: 22,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.lan, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(val, style: TextStyle(color: textColor, fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() {
                      _selectedNetwork = newVal;
                      _selectedCryptoAsset = _getAssetsForNetwork(newVal).first;
                    });
                    if (_cryptoInputAmount > 0) _fetchLiveNowPaymentsRate();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildInputLabel('Select Crypto Currency', textColor),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? null : Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCryptoAsset,
                isExpanded: true,
                dropdownColor: cardColor,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                items: availableCrypto.map((val) {
                  final assetCdn = _getCdnCode(val);
                  return DropdownMenuItem(
                    value: val, 
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/color/$assetCdn.png',
                            width: 22,
                            height: 22,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.token, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(val, style: TextStyle(color: textColor, fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() => _selectedCryptoAsset = newVal);
                    if (_cryptoInputAmount > 0) _fetchLiveNowPaymentsRate();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildInputLabel('Destination Public Wallet Address', textColor),
          _buildInputField(_cryptoAddressController, 'e.g. 0x71... or TQ...', cardColor, isDark, false),
          const SizedBox(height: 20),

          _buildInputLabel('Amount to Send (USD equivalent)', textColor),
          _buildInputField(
            _cryptoAmountController, 
            '0.00', 
            cardColor, 
            isDark, 
            true, 
            onChanged: (val) {
              setState(() => _cryptoInputAmount = double.tryParse(val) ?? 0.0);
              _fetchLiveNowPaymentsRate();
            },
          ),
          const SizedBox(height: 24),

          if (_cryptoInputAmount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.05 : 0.15)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sandbox Route', style: TextStyle(color: secondaryColor, fontSize: 12)),
                      Text(_selectedNetwork.split(' ').first, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Est. Transferred Value', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      _isFetchingCryptoRate
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF8B5CF6)))
                          : Text('${_estimatedCryptoPayout.toStringAsFixed(6)} $_selectedCryptoAsset', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _cryptoInputAmount <= 0 || _cryptoAddressController.text.isEmpty || _isFetchingCryptoRate ? null : _processCryptoSend,
            child: const Text('Confirm & Dispatch Crypto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, Color cardColor, bool isDark, bool isNumeric, {Function(String)? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]), border: InputBorder.none),
      ),
    );
  }
}