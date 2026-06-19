import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiveFundsScreen extends StatefulWidget {
  const ReceiveFundsScreen({super.key});

  @override
  State<ReceiveFundsScreen> createState() => _ReceiveFundsScreenState();
}

class _ReceiveFundsScreenState extends State<ReceiveFundsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fiatDepositSimulationController = TextEditingController();
  final _cryptoDepositSimulationController = TextEditingController();

  String _selectedFiatCurrency = 'USD';
  String _selectedNetwork = 'TRC20 (TRON)';
  String _selectedCryptoAsset = 'USDT';
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

  String _getMockAddress(String network) {
    switch (network) {
      case 'TRC20 (TRON)':
        return 'TYuXp9G8bHnN2jSqR2pA8bE6fG7hR3aK9j';
      case 'BEP20 (BSC)':
        return '0x8bF2405F7C5f9B6579E9fE305EfCcCd4f762C12A';
      case 'ERC20 (Ethereum)':
        return '0x7a84e9f9A821A8bE6E30cCcCd4f762A7a84e9fB2';
      case 'BTC (Bitcoin Mainnet)':
        return 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
      case 'SOL (Solana Native)':
        return 'HN7c6HSSdfE39nS4K4GgH9R3jKsP9pSkjS39s';
      default:
        return '0x7a84e9f9A821A8bE6E30cCcCd4f762A7a84e9fB2';
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
    _fiatDepositSimulationController.dispose();
    _cryptoDepositSimulationController.dispose();
    super.dispose();
  }

  Future<void> _simulateDepositReceipt(bool isCrypto) async {
    final double depositAmount = double.tryParse(isCrypto ? _cryptoDepositSimulationController.text : _fiatDepositSimulationController.text) ?? 0.0;
    final String assetName = isCrypto ? _selectedCryptoAsset : _selectedFiatCurrency;

    if (depositAmount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        // Grab current live balances from Supabase
        final response = await client.from('wallets').select().eq('user_id', userId).maybeSingle();
        double currentFiatBalance = response != null ? (response['balance'] ?? 0.0).toDouble() : 0.0;
        double currentCryptoBalance = response != null ? (response['crypto_balance'] ?? 0.0).toDouble() : 0.0;

        double newFiatBalance = currentFiatBalance;
        double newCryptoBalance = currentCryptoBalance;

        if (isCrypto) {
          newCryptoBalance += depositAmount;
        } else {
          newFiatBalance += depositAmount;
        }

        // Upsert back to wallets database
        await client.from('wallets').upsert({
          'user_id': userId,
          'balance': newFiatBalance,
          'crypto_balance': newCryptoBalance,
        });

        // Trigger dynamic system notifications log insertion
        try {
          await client.from('notifications').insert({
            'user_id': userId,
            'title': isCrypto ? 'Crypto Received' : 'FIAT Deposit Confirmed',
            'message': 'You have received ${depositAmount.toStringAsFixed(2)} $assetName from an external source.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // Fail gracefully if database table 'notifications' doesn't exist
        }

        // Trigger beautiful in-app system notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Payment Credited Successfully',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Received $depositAmount $assetName! Dashboard updated in real-time.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          _fiatDepositSimulationController.clear();
          _cryptoDepositSimulationController.clear();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error updating wallet balances: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    
    // Fixed nullability constraint by adding non-nullable assertions (!) to gray swatches
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Receive Funds',
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
            Tab(icon: Icon(Icons.account_balance_outlined), text: 'FIAT Account'),
            Tab(icon: Icon(Icons.qr_code_2_rounded), text: 'Crypto Scanner'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFiatReceiveView(cardColor, elementBgColor, textColor, secondaryTextColor, accentColor, isDark),
                _buildCryptoReceiveView(cardColor, elementBgColor, textColor, secondaryTextColor, accentColor, isDark),
              ],
            ),
    );
  }

  Widget _buildFiatReceiveView(Color cardColor, Color elementBg, Color textColor, Color secondaryColor, Color accentColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? null : Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, color: accentColor, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Flutterwave Virtual Core Account',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bank: Providus Bank • Acct: 9948210385',
                  style: TextStyle(color: secondaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Account Holder: Lawrence Stable Ledger',
                  style: TextStyle(color: secondaryColor, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'DEMO TEST RECEIVE SIMULATOR',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Since you are testing in sandbox corridors, use this simulator block to deposit virtual FIAT balances immediately and verify your dashboard updates.',
            style: TextStyle(color: secondaryColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _buildInputLabel('Select Currency Pipeline', textColor),
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
          const SizedBox(height: 16),
          _buildInputLabel('Amount to Receive (\$)', textColor),
          _buildInputField(_fiatDepositSimulationController, 'Enter simulated amount (e.g. 500)', cardColor, isDark),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _simulateDepositReceipt(false),
            child: const Text('Simulate Inbound Flutterwave Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoReceiveView(Color cardColor, Color elementBg, Color textColor, Color secondaryColor, Color accentColor, bool isDark) {
    final availableCrypto = _getAssetsForNetwork(_selectedNetwork);
    if (!availableCrypto.contains(_selectedCryptoAsset)) {
      _selectedCryptoAsset = availableCrypto.first;
    }
    final String activeAddress = _getMockAddress(_selectedNetwork);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputLabel('Target Network', textColor),
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
                  if (newVal != null) setState(() => _selectedNetwork = newVal);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomPaint(
                size: const Size(180, 180),
                painter: QrPainter(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Your Web3 $activeAddress',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryColor, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.copy, size: 16, color: Color(0xFF8B5CF6)),
              label: const Text('Copy Address', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: activeAddress));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address copied to clipboard!')),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'SIMULATED INBOUND DEPOSIT BLOCK',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildInputLabel('Select Token Type', textColor),
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
          const SizedBox(height: 16),
          _buildInputLabel('Simulate Inbound Amount', textColor),
          _buildInputField(_cryptoDepositSimulationController, 'e.g. 1.25', cardColor, isDark),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _simulateDepositReceipt(true),
            child: const Text('Simulate Inbound Wallet Deposit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildInputField(TextEditingController controller, String hint, Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRect(const Rect.fromLTWH(0, 0, 40, 40), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 40, 0, 40, 40), paint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 40, 40, 40), paint);

    canvas.drawRect(const Rect.fromLTWH(60, 20, 20, 40), paint);
    canvas.drawRect(const Rect.fromLTWH(100, 0, 40, 20), paint);
    canvas.drawRect(const Rect.fromLTWH(20, 60, 40, 20), paint);
    canvas.drawRect(const Rect.fromLTWH(80, 80, 40, 40), paint);
    canvas.drawRect(const Rect.fromLTWH(140, 60, 20, 60), paint);
    canvas.drawRect(const Rect.fromLTWH(60, 140, 40, 20), paint);
    canvas.drawRect(const Rect.fromLTWH(120, 140, 40, 40), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}