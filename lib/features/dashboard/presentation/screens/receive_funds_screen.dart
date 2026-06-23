import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_money_screen.dart';

class ReceiveFundsScreen extends StatefulWidget {
  const ReceiveFundsScreen({super.key});

  @override
  State<ReceiveFundsScreen> createState() => _ReceiveFundsScreenState();
}

class _ReceiveFundsScreenState extends State<ReceiveFundsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _cryptoDepositSimulationController = TextEditingController();

  String _selectedNetwork = 'TRC20 (TRON)';
  String _selectedCryptoAsset = 'USDT';
  bool _isLoading = false;

  // Fully matched list of enterprise networks supported by the NOWPayments gateway
  final List<String> _networks = [
    'TRC20 (TRON)',
    'BEP20 (BSC)',
    'ERC20 (Ethereum)',
    'BTC (Bitcoin Mainnet)',
    'SOL (Solana Native)',
    'ADA (Cardano Native)',
    'DOGE (Dogecoin)',
    'POLYGON (Matic)',
    'Arbitrum (ERC20)',
    'Optimism (ERC20)',
    'AVAX (Avalanche C-Chain)',
  ];

  // Dynamically maps which crypto tokens exist natively on the chosen network
  List<String> _getAssetsForNetwork(String network) {
    switch (network) {
      case 'TRC20 (TRON)':
        return ['USDT', 'TRX', 'USDC', 'BUSD', 'SUN', 'JST'];
      case 'BEP20 (BSC)':
        return ['BNB', 'USDT', 'USDC', 'BUSD', 'CAKE', 'ALPHA', 'BAKE', 'SFP'];
      case 'ERC20 (Ethereum)':
        return [
          'ETH',
          'USDT',
          'USDC',
          'LINK',
          'UNI',
          'AAVE',
          'SHIB',
          'PEPE',
          'GRT',
          'MKR',
          'COMP',
          'MANA',
          'SAND',
        ];
      case 'BTC (Bitcoin Mainnet)':
        return ['BTC', 'WBTC'];
      case 'SOL (Solana Native)':
        return ['SOL', 'USDT', 'USDC', 'RAY', 'FIDA'];
      case 'ADA (Cardano Native)':
        return ['ADA'];
      case 'DOGE (Dogecoin)':
        return ['DOGE'];
      case 'POLYGON (Matic)':
        return ['MATIC', 'USDT', 'USDC', 'SAND', 'QUICK'];
      case 'Arbitrum (ERC20)':
        return ['ARB', 'USDT', 'USDC', 'ETH'];
      case 'Optimism (ERC20)':
        return ['OP', 'USDT', 'USDC', 'ETH'];
      case 'AVAX (Avalanche C-Chain)':
        return ['AVAX', 'USDT', 'USDC'];
      default:
        return ['USDT'];
    }
  }

  // Resolves custom NOWPayments mock addresses mapped to specific networks
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
      case 'ADA (Cardano Native)':
        return 'addr1q9jxtg46ygr7asgdn79qyf583p64lkfjh8wlhw';
      case 'DOGE (Dogecoin)':
        return 'DJf89a2LdGjSqzTxQR2PA8Be6FG7HR3AK9j';
      case 'POLYGON (Matic)':
        return '0x2A7a84e9fB27a84e9f9A821A8bE6E30cCcCd4f76';
      case 'Arbitrum (ERC20)':
        return '0x9A821A8bE6E30cCcCd4f762A7a84e9fB27a84e9f';
      case 'Optimism (ERC20)':
        return '0xeE30cCcCd4f762A7a84e9fB27a84e9fB27a84e9fB';
      case 'AVAX (Avalanche C-Chain)':
        return '0x8e6E30cCcCd4f762A7a84e9fB27a84e9fB27a84e9';
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
    _cryptoDepositSimulationController.dispose();
    super.dispose();
  }

  Future<void> _simulateDepositReceipt() async {
    final double depositAmount = double.tryParse(_cryptoDepositSimulationController.text) ?? 0.0;
    final String assetName = _selectedCryptoAsset;

    if (depositAmount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        final response = await client.from('wallets').select().eq('user_id', userId).maybeSingle();
        double currentCryptoBalance = response != null ? (response['crypto_balance'] ?? 0.0).toDouble() : 0.0;
        double newCryptoBalance = currentCryptoBalance + depositAmount;

        await client.from('wallets').upsert({
          'user_id': userId,
          'crypto_balance': newCryptoBalance,
        });

        try {
          await client.from('notifications').insert({
            'user_id': userId,
            'title': 'Crypto Received',
            'message': 'You have received ${depositAmount.toStringAsFixed(2)} $assetName from an external source.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}

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
    const accentColor = Color(0xFF10B981);
    final elementBgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
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
            Tab(icon: Icon(Icons.account_balance_outlined), text: 'FIAT Deposit'),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.account_balance_wallet_rounded, color: accentColor, size: 80),
          const SizedBox(height: 24),
          Text(
            'Deposit FIAT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add money safely to your fiat wallet using our Flutterwave payment gateway corridor. Supported channels include Cards, Bank Transfer, and USSD.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: isDark ? 0 : 2,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMoneyScreen()),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Deposit FIAT Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  if (newVal != null) {
                    setState(() {
                      _selectedNetwork = newVal;
                      final networkAssets = _getAssetsForNetwork(newVal);
                      if (networkAssets.isNotEmpty) {
                        _selectedCryptoAsset = networkAssets.first;
                      }
                    });
                  }
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
              'Your Web3 Address:',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              activeAddress,
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
            onPressed: _simulateDepositReceipt,
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