import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SendFundsScreen extends StatefulWidget {
  const SendFundsScreen({super.key});

  @override
  State<SendFundsScreen> createState() => _SendFundsScreenState();
}

class _SendFundsScreenState extends State<SendFundsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fiatAmountController = TextEditingController();
  final _fiatRecipientController = TextEditingController();
  final _cryptoAmountController = TextEditingController();
  final _cryptoAddressController = TextEditingController();

  String _selectedFiatCurrency = 'USD';
  String _selectedNetwork = 'TRC20 (TRON)';
  String _selectedCryptoAsset = 'USDT';
  double _fiatInputAmount = 0.0;
  double _cryptoInputAmount = 0.0;
  bool _isLoading = false;

  final List<String> _fiatCurrencies = ['USD', 'NGN', 'GHS', 'KES', 'EUR', 'GBP'];
  final List<String> _networks = [
    'TRC20 (TRON)',
    'BEP20 (BSC)',
    'ERC20 (Ethereum)',
    'BTC (Bitcoin Mainnet)',
    'SOL (Solana Native)'
  ];

  List<String> _getAssetsForNetwork(String network) {
    switch (network) {
      case 'TRC20 (TRON)':
        return ['USDT', 'TRX', 'USDC'];
      case 'BEP20 (BSC)':
        return ['BNB', 'USDT', 'BUSD'];
      case 'ERC20 (Ethereum)':
        return ['ETH', 'USDT', 'LINK'];
      case 'BTC (Bitcoin Mainnet)':
        return ['BTC', 'WBTC'];
      case 'SOL (Solana Native)':
        return ['SOL', 'USDT', 'USDC'];
      default:
        return ['USDT'];
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fiatAmountController.dispose();
    _fiatRecipientController.dispose();
    _cryptoAmountController.dispose();
    _cryptoAddressController.dispose();
    super.dispose();
  }

  Future<void> _processSend(bool isCrypto) async {
    final double sendAmount = isCrypto ? _cryptoInputAmount : _fiatInputAmount;
    final String assetName = isCrypto ? _selectedCryptoAsset : _selectedFiatCurrency;
    final String destination = isCrypto ? _cryptoAddressController.text : _fiatRecipientController.text;

    if (sendAmount <= 0 || destination.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        // Fetch current live balances
        final response = await client.from('wallets').select().eq('user_id', userId).maybeSingle();
        double currentFiatBalance = response != null ? (response['balance'] ?? 0.0).toDouble() : 0.0;
        double currentCryptoBalance = response != null ? (response['crypto_balance'] ?? 0.0).toDouble() : 0.0;

        double newFiatBalance = currentFiatBalance;
        double newCryptoBalance = currentCryptoBalance;

        if (isCrypto) {
          if (currentCryptoBalance < sendAmount) {
            _showErrorSnackbar('Insufficient Web3 Crypto balance for this transaction.');
            return;
          }
          newCryptoBalance -= sendAmount;
        } else {
          if (currentFiatBalance < sendAmount) {
            _showErrorSnackbar('Insufficient FIAT balance for this transaction.');
            return;
          }
          newFiatBalance -= sendAmount;
        }

        // Persist subtracted balances back to wallets database
        await client.from('wallets').upsert({
          'user_id': userId,
          'balance': newFiatBalance,
          'crypto_balance': newCryptoBalance,
        });

        // Trigger database notification entry
        try {
          await client.from('notifications').insert({
            'user_id': userId,
            'title': isCrypto ? 'Crypto Transferred' : 'FIAT Sent Out',
            'message': 'Successfully sent ${sendAmount.toStringAsFixed(2)} $assetName to $destination.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // Fallback gracefully if database notifications table isn't created yet
        }

        // Display beautiful in-app system notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFEF4444),
              content: Row(
                children: [
                  const Icon(Icons.outbound_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Transaction Dispatched',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Successfully sent $sendAmount $assetName to $destination!',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Transaction failed: $e');
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
    const accentColor = Color(0xFF10B981); // Brand Green
    final elementBgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    
    // Fixed nullability constraint by adding non-nullable assertions (!) to Swatches
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
            Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'FIAT Wallet'),
            Tab(icon: Icon(Icons.currency_bitcoin_rounded), text: 'Crypto Wallet'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFiatSendView(cardColor, elementBgColor, textColor, secondaryTextColor, accentColor, isDark),
                _buildCryptoSendView(cardColor, elementBgColor, textColor, secondaryTextColor, accentColor, isDark),
              ],
            ),
    );
  }

  Widget _buildFiatSendView(Color cardColor, Color elementBg, Color textColor, Color secondaryColor, Color accentColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transfer FIAT funds out of your traditional core bank balance immediately.',
            style: TextStyle(color: secondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _buildInputLabel('Select Currency Token', textColor),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? null : Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFiatCurrency,
                isExpanded: true,
                dropdownColor: cardColor,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                items: _fiatCurrencies.map((val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) setState(() => _selectedFiatCurrency = newVal);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputLabel('Recipient Email or User Tag', textColor),
          _buildInputField(_fiatRecipientController, 'e.g. user@fintech.com or @lawrence', cardColor, isDark, false),
          const SizedBox(height: 20),
          _buildInputLabel('Amount to Send', textColor),
          _buildInputField(_fiatAmountController, '0.00', cardColor, isDark, true, onChanged: (val) {
            setState(() => _fiatInputAmount = double.tryParse(val) ?? 0.0);
          }),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _fiatInputAmount <= 0 || _fiatRecipientController.text.isEmpty
                ? null
                : () => _processSend(false),
            child: const Text('Confirm & Transfer FIAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoSendView(Color cardColor, Color elementBg, Color textColor, Color secondaryColor, Color accentColor, bool isDark) {
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
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() {
                      _selectedNetwork = newVal;
                      _selectedCryptoAsset = _getAssetsForNetwork(newVal).first;
                    });
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
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) setState(() => _selectedCryptoAsset = newVal);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputLabel('Destination Public Wallet Address', textColor),
          _buildInputField(_cryptoAddressController, 'e.g. 0x71... or TQ...', cardColor, isDark, false),
          const SizedBox(height: 20),
          _buildInputLabel('Amount to Send', textColor),
          _buildInputField(_cryptoAmountController, '0.00', cardColor, isDark, true, onChanged: (val) {
            setState(() => _cryptoInputAmount = double.tryParse(val) ?? 0.0);
          }),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _cryptoInputAmount <= 0 || _cryptoAddressController.text.isEmpty
                ? null
                : () => _processSend(true),
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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
          border: InputBorder.none,
        ),
      ),
    );
  }
}