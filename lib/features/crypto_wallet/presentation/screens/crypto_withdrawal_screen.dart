import 'package:flutter/material.dart';

class CryptoWithdrawalScreen extends StatefulWidget {
  const CryptoWithdrawalScreen({super.key});

  @override
  State<CryptoWithdrawalScreen> createState() => _CryptoWithdrawalScreenState();
}

class _CryptoWithdrawalScreenState extends State<CryptoWithdrawalScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedNetwork = 'TRC20 (TRON)';
  String _selectedCrypto = 'USDT';
  double _inputAmount = 0.0;
  bool _isLoading = false;

  // Premium system palette matching dashboard alignments
  static const Color emeraldColor = Color(0xFF10B981);
  static const Color warningRedColor = Color(0xFFEF4444);
  static const Color brandOrangeColor = Color(0xFFFBBF24);

  // Supported gateway blockchains list
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

  // Maps which crypto tokens exist natively on the currently selected network
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

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _calculateWithdrawal(String val) {
    setState(() {
      _inputAmount = double.tryParse(val) ?? 0.0;
    });
  }

  void _executeWithdrawalFlow() async {
    if (_addressController.text.isEmpty || _inputAmount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Withdrawal of $_inputAmount $_selectedCrypto successfully queued via $_selectedNetwork processing corridors.',
          ),
          backgroundColor: emeraldColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final double saasFee = _inputAmount * 0.01;
    final double netPayout = _inputAmount > saasFee
        ? _inputAmount - saasFee
        : 0.0;

    // Get the dynamic list of assets available for the currently chosen network
    final availableAssets = _getAssetsForNetwork(_selectedNetwork);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Withdraw Crypto',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF111622) : Colors.white,
        elevation: 0,
        shape: isDark
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: brandOrangeColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Withdraw funds directly from your Web3 Smart Wallet out to any public decentralized blockchain network.',
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 1. SELECT BLOCKCHAIN NETWORK DROPDOWN (UPPERMOST INPUT)
                  // ==========================================
                  Text(
                    'Select Target Blockchain Network',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? null
                          : Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedNetwork,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? const Color(0xFF111622)
                            : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: secondaryTextColor,
                          size: 24,
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        items: _networks.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lan,
                                  color: brandOrangeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedNetwork = newValue;
                              // Auto-select the first valid asset for this newly selected network to avoid drop-down index bugs
                              final networkAssets = _getAssetsForNetwork(newValue);
                              if (networkAssets.isNotEmpty) {
                                _selectedCrypto = networkAssets.first;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 2. DYNAMIC CRYPTO ASSET DROPDOWN
                  // ==========================================
                  Text(
                    'Select Asset to Withdraw',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? null
                          : Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCrypto,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? const Color(0xFF111622)
                            : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: secondaryTextColor,
                          size: 24,
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        items: availableAssets.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.currency_bitcoin,
                                  color: brandOrangeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCrypto = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 3. DESTINATION WALLET ADDRESS FIELD
                  // ==========================================
                  Text(
                    'Destination Wallet Address',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? null
                          : Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _addressController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Paste public address (e.g. 0x... or Tx...)',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 4. AMOUNT TO WITHDRAW (USD)
                  // ==========================================
                  Text(
                    'Amount to Withdraw (USD)',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? null
                          : Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: _calculateWithdrawal,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 5. SAAS BREAKDOWN MATRIX LEDGER
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(
                          alpha: isDark ? 0.05 : 0.2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SaaS Processing Fee (1%)',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '\$${saasFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: warningRedColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.grey, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Net Payout to Wallet',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${netPayout.toStringAsFixed(2)} (Est. in $_selectedCrypto)',
                              style: const TextStyle(
                                color: emeraldColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ==========================================
                  // 6. CONFIRM AND SEND OUT ACTION BUTTON
                  // ==========================================
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrangeColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        _addressController.text.isEmpty || _inputAmount <= 0
                            ? null
                            : _executeWithdrawalFlow,
                    child: const Text(
                      'Confirm & Send Out',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}