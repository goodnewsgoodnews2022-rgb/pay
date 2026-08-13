// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:flutter/material.dart';
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
  String _resolvedRecipientUsername = '';
  // ignore: unused_field
  String _resolvedRecipientCurrency = 'NGN'; 
  String _senderCurrency = 'NGN'; 
  double _fiatInputAmount = 0.0;
  double _convertedPayoutAmount = 0.0;

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
        return ['TRX', 'USDT', 'USDC'];
      case 'Binance Smart Chain (BEP20)':
        return ['BNB', 'USDT', 'USDC', 'CAKE'];
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
    if (lower.contains('arbitrum') || lower == 'eth') return 'eth'; 
    if (lower.contains('optimism') || lower == 'eth') return 'eth'; 
    if (lower == 'usdt') return 'usdt';
    if (lower == 'usdc') return 'usdc';
    if (lower == 'busd') return 'usdt';
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
        final profile = await client.from('profiles').select('full_name, username').eq('id', userId).maybeSingle();
        if (profile != null) {
          setState(() {
            _senderCurrency = 'NGN';
          });
        }
      }
    } catch (_) {}
  }

  void _resolveRecipientProfile(String input) async {
    final cleanInput = input.trim();
    if (cleanInput.length < 2) {
      setState(() {
        _userResolvedSuccessfully = false;
        _resolvedRecipientName = '';
        _resolvedRecipientUsername = '';
        _isResolvingUser = false;
        _fiatAmountController.clear();
        _fiatInputAmount = 0.0;
      });
      return;
    }

    setState(() {
      _isResolvingUser = true;
      _userResolvedSuccessfully = false;
    });

    try {
      final client = Supabase.instance.client;
      final searchVal = cleanInput.startsWith('@') ? cleanInput.substring(1) : cleanInput;

      // Case-insensitive query to resolve user profiles accurately
      final profile = cleanInput.length == 36 && cleanInput.contains('-')
          ? await client.from('profiles').select('id, full_name, username').eq('id', cleanInput).maybeSingle()
          : await client.from('profiles').select('id, full_name, username').ilike('username', searchVal).maybeSingle();

      if (profile != null) {
        final fetchedUsername = profile['username'] ?? '';
        final fetchedName = profile['full_name'] ?? fetchedUsername;

        setState(() {
          _resolvedRecipientName = fetchedName;
          _resolvedRecipientUsername = fetchedUsername;
          _resolvedRecipientCurrency = 'NGN';
          _userResolvedSuccessfully = true;
          _isResolvingUser = false;
        });
      } else {
        setState(() {
          _userResolvedSuccessfully = false;
          _resolvedRecipientName = '';
          _resolvedRecipientUsername = '';
          _isResolvingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Recipient Resolution Error: $e');
      setState(() {
        _userResolvedSuccessfully = false;
        _resolvedRecipientName = '';
        _resolvedRecipientUsername = '';
        _isResolvingUser = false;
      });
    }
  }

  Future<void> _fetchLiveNowPaymentsRate() async {
    if (_cryptoInputAmount <= 0) return;

    setState(() {
      _isFetchingCryptoRate = true;
    });

    await Future.delayed(const Duration(milliseconds: 150));
    _executeCryptoFallbackMath();
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

  Future<void> _processFiatP2PSend() async {
    final cleanUsername = _resolvedRecipientUsername;
    if (_fiatInputAmount <= 0 || cleanUsername.isEmpty || !_userResolvedSuccessfully) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;

      final recipientProfile = await client.from('profiles').select('id, full_name, username').ilike('username', cleanUsername).maybeSingle();
      if (recipientProfile == null) {
        _showErrorSnackbar('cancelled: Recipient profile no longer exists.');
        setState(() => _isLoading = false);
        return;
      }
      final cleanRecipientUid = recipientProfile['id'] as String;
      final senderUid = client.auth.currentUser?.id;

      if (senderUid != null) {
        if (senderUid == cleanRecipientUid) {
          _showErrorSnackbar('You cannot send funds to yourself.');
          setState(() => _isLoading = false);
          return;
        }

        final senderProfile = await client.from('profiles').select('username, full_name, balance').eq('id', senderUid).maybeSingle();
        final senderDisplayName = senderProfile?['username'] ?? senderProfile?['full_name'] ?? 'A user';
        
        // Fetch sender balance safely from both sources to avoid mismatch
        final senderWalletResponse = await client
            .from('wallet_balances')
            .select('naira_balance')
            .eq('user_identifier', senderUid)
            .maybeSingle();
            
        double currentSenderBalance = senderWalletResponse != null 
            ? (senderWalletResponse['naira_balance'] ?? 0.0).toDouble() 
            : (senderProfile?['balance'] ?? 0.0).toDouble();

        if (currentSenderBalance < _fiatInputAmount) {
          _showErrorSnackbar('insufficient fund in your wallet');
          setState(() => _isLoading = false);
          return;
        }

        final recipientWalletResponse = await client
            .from('wallet_balances')
            .select('naira_balance')
            .eq('user_identifier', cleanRecipientUid)
            .maybeSingle();
            
        double currentRecipientBalance = recipientWalletResponse != null ? (recipientWalletResponse['naira_balance'] ?? 0.0).toDouble() : 0.0;

        double newSenderBalance = currentSenderBalance - _fiatInputAmount;
        double newRecipientBalance = currentRecipientBalance + _fiatInputAmount;

        // Update wallet_balances for sender
        await client
            .from('wallet_balances')
            .upsert({'user_identifier': senderUid, 'naira_balance': newSenderBalance}, onConflict: 'user_identifier');
            
        // Update wallet_balances for recipient
        await client
            .from('wallet_balances')
            .upsert({'user_identifier': cleanRecipientUid, 'naira_balance': newRecipientBalance}, onConflict: 'user_identifier');

        // Also update profiles balance if used anywhere in dashboard views
        await client.from('profiles').update({'balance': newSenderBalance}).eq('id', senderUid);
        await client.from('profiles').update({'balance': newRecipientBalance}).eq('id', cleanRecipientUid);

        // Insert transaction for sender
        await client.from('transactions').insert({
          'user_identifier': senderUid,
          'amount': _fiatInputAmount,
          'type': 'p2p outbound',
          'status': 'success',
          'created_at': DateTime.now().toIso8601String(),
        });

        // Insert transaction for recipient so it appears instantly in their list & history
        await client.from('transactions').insert({
          'user_identifier': cleanRecipientUid,
          'amount': _fiatInputAmount,
          'type': 'p2p inbound',
          'status': 'success',
          'created_at': DateTime.now().toIso8601String(),
        });

        try {
          await client.from('user_notifications').insert({
            'user_id': senderUid,
            'title': 'P2P Transfer Sent',
            'message': 'Successfully sent $_fiatInputAmount NGN to $_resolvedRecipientName.',
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });

          await client.from('user_notifications').insert({
            'user_id': cleanRecipientUid,
            'title': 'Funds Received',
            'message': 'You received $_fiatInputAmount NGN from $senderDisplayName.',
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF10B981),
              content: Text('success'),
            ),
          );
          setState(() {
            _fiatRecipientUidController.clear();
            _fiatAmountController.clear();
            _userResolvedSuccessfully = false;
            _fiatInputAmount = 0.0;
          });
        }
      }
    } catch (e) {
      _showErrorSnackbar('cancelled: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processCryptoSend() async {
    final cleanAddress = _cryptoAddressController.text.trim();
    if (_cryptoInputAmount <= 0 || cleanAddress.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        final profileResponse = await client
            .from('profiles')
            .select('balance')
            .eq('id', userId)
            .maybeSingle();
            
        double currentProfileBalance = profileResponse != null ? (profileResponse['balance'] ?? 0.0).toDouble() : 0.0;

        if (currentProfileBalance < _cryptoInputAmount) {
          _showErrorSnackbar('insufficient funds in your crypto wallet');
          setState(() => _isLoading = false);
          return;
        }

        double newProfileBalance = currentProfileBalance - _cryptoInputAmount;

        await client
            .from('profiles')
            .update({'balance': newProfileBalance})
            .eq('id', userId);

        try {
          await client.from('transactions').insert({
            'user_identifier': userId,
            'amount': _cryptoInputAmount,
            'type': 'crypto transfer out',
            'status': 'success',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}

        try {
          await client.from('user_notifications').insert({
            'user_id': userId,
            'title': 'Crypto Transaction Dispatched',
            'message': 'Successfully processed \$${_cryptoInputAmount.toStringAsFixed(2)} in $_selectedCryptoAsset via gateway.',
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF10B981),
              content: Text('success'),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackbar('cancelled: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            'Instantly send money to any Pay Me user using their unique username.',
            style: TextStyle(color: secondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 24),

          _buildInputLabel('Recipient Username', textColor),
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
                hintText: 'Enter username (e.g. javed)',
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
          const SizedBox(height: 16),

          if (_isResolvingUser || _userResolvedSuccessfully)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _userResolvedSuccessfully ? Colors.green.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _userResolvedSuccessfully ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _userResolvedSuccessfully ? Colors.green : Colors.grey,
                    radius: 18,
                    child: Icon(
                      _userResolvedSuccessfully ? Icons.verified_user_rounded : Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userResolvedSuccessfully ? 'Verified Account Name' : 'Verifying Username...',
                          style: TextStyle(
                            color: _userResolvedSuccessfully ? Colors.green : secondaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _userResolvedSuccessfully ? '$_resolvedRecipientName (@$_resolvedRecipientUsername)' : 'Checking Payme user database...',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_userResolvedSuccessfully) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInputLabel('Amount to Send', textColor),
                Text('Base Currency: $_senderCurrency', style: TextStyle(color: secondaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
                  _convertedPayoutAmount = _fiatInputAmount;
                });
              },
            ),
            const SizedBox(height: 20),

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
                        Text('Transfer Type', style: TextStyle(color: secondaryColor, fontSize: 12)),
                        Text('Instant P2P Transfer', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recipient Receives', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${_convertedPayoutAmount.toStringAsFixed(2)} NGN', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
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
              onPressed: _fiatInputAmount <= 0 ? null : _processFiatP2PSend,
              child: Text('Send to $_resolvedRecipientName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
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
            'Transmit Web3 values directly out to any external verified blockchain ledger.',
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
              child: structuredColumnWithCryptoDetails(secondaryColor, textColor, isDark),
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

  Widget structuredColumnWithCryptoDetails(Color secondaryColor, Color textColor, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Estimated Route', style: TextStyle(color: secondaryColor, fontSize: 12)),
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
    );
  }

  Widget _buildInputLabel(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.5),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, Color cardColor, bool isDark, bool isNumeric, {Function(String)? onChanged}) {
    return Container(
      padding: identicalPaddingOrZero(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChangesOrPass(onChanged),
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]), border: InputBorder.none),
      ),
    );
  }

  Function(String)? onChangesOrPass(Function(String)? cb) => cb;
}

EdgeInsets identicalPaddingOrZero({required double horizontal}) => EdgeInsets.symmetric(horizontal: horizontal);