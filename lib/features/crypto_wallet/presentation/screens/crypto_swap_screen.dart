import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto_swap_bloc.dart';
import '../bloc/crypto_swap_event.dart';
import '../bloc/crypto_swap_state.dart';

class CryptoSwapScreen extends StatefulWidget {
  const CryptoSwapScreen({super.key});

  @override
  State<CryptoSwapScreen> createState() => _CryptoSwapScreenState();
}

class _CryptoSwapScreenState extends State<CryptoSwapScreen> {
  final _amountController = TextEditingController();

  // ==========================================
  // COMPLETE NOWPAYMENTS FIAT REGISTRY (75+)
  // ==========================================
  final List<String> _fiatCurrencies = [
    'AED', 'AFN', 'ALL', 'AMD', 'ANG', 'AOA', 'ARS', 'AUD', 'AWG', 'AZN',
    'BAM', 'BBD', 'BDT', 'BGN', 'BHD', 'BIF', 'BMD', 'BND', 'BOB', 'BRL',
    'BSD', 'BWP', 'BYN', 'BZD', 'CAD', 'CDF', 'CHF', 'CLP', 'CNY', 'COP',
    'CRC', 'CVE', 'CZK', 'DJF', 'DKK', 'DOP', 'DZD', 'EGP', 'ETB', 'EUR',
    'FJD', 'FKP', 'GBP', 'GEL', 'GHS', 'GIP', 'GMD', 'GNF', 'GTQ', 'GYD',
    'HKD', 'HNL', 'HRK', 'HTG', 'HUF', 'IDR', 'ILS', 'INR', 'IQD', 'ISK',
    'JMD', 'JOD', 'JPY', 'KES', 'KGS', 'KHR', 'KMF', 'KRW', 'KWD', 'KYD',
    'KZT', 'LAK', 'LBP', 'LKR', 'LRD', 'LSL', 'LYD', 'MAD', 'MDL', 'MGA',
    'MKD', 'MMK', 'MNT', 'MOP', 'MRU', 'MUR', 'MVR', 'MWK', 'MXN', 'MYR',
    'MZN', 'NAD', 'NGN', 'NIO', 'NOK', 'NPR', 'NZD', 'OMR', 'PAB', 'PEN',
    'PGK', 'PHP', 'PKR', 'PLN', 'PYG', 'QAR', 'RON', 'RSD', 'RUB', 'RWF',
    'SAR', 'SBD', 'SCR', 'SDG', 'SEK', 'SGD', 'SHP', 'SLL', 'SOS', 'SRD',
    'STN', 'SVC', 'SZL', 'THB', 'TJS', 'TMT', 'TND', 'TOP', 'TRY', 'TTD',
    'TWD', 'TZS', 'UAH', 'UGX', 'USD', 'UYU', 'UZS', 'VES', 'VND', 'VUV',
    'WST', 'XAF', 'XCD', 'XOF', 'XPF', 'YER', 'ZAR', 'ZMW', 'ZWL'
  ]..sort();

  // ==========================================
  // COMPLETE NOWPAYMENTS CRYPTO REGISTRY (350+)
  // ==========================================
  final List<String> _cryptoCurrencies = [
    '1INCH', 'AAVE', 'ADA', 'AGIX', 'AKRO', 'ALGO', 'ALICE', 'ALPHA', 'ANKR', 'ANT',
    'APE', 'API3', 'APT', 'AR', 'ARB', 'ARK', 'ASTR', 'ATOM', 'AUDIO', 'AVAX',
    'AXS', 'BADGER', 'BAL', 'BAND', 'BAT', 'BCH', 'BEL', 'BICO', 'BLUR', 'BNB',
    'BNT', 'BSV', 'BTC', 'BTT', 'BUSD', 'C98', 'CAKE', 'CELO', 'CELR', 'CHZ',
    'CKB', 'COMP', 'CORE', 'COTI', 'CRV', 'CTSI', 'CVC', 'DAI', 'DASH', 'DCR',
    'DGB', 'DIA', 'DODO', 'DOGE', 'DOT', 'DYDX', 'EGLD', 'ENJ', 'ENS', 'EOS',
    'ETC', 'ETH', 'EURA', 'FIDA', 'FIL', 'FITFI', 'FLOW', 'FLR', 'FLOKI', 'FORTH',
    'FRONT', 'FTM', 'FXS', 'GALA', 'GARI', 'GAS', 'GLMR', 'GMT', 'GMX', 'GNO',
    'GRT', 'GTC', 'GUSD', 'HBAR', 'HIGH', 'HNT', 'HOT', 'ICP', 'ICX', 'ILV',
    'IMX', 'INJ', 'IOST', 'IOTA', 'IOTX', 'JASMY', 'JOE', 'JST', 'KAVA', 'KDA',
    'KEEP', 'KNC', 'KSM', 'LDO', 'LEO', 'LINA', 'LINK', 'LPT', 'LRC', 'LTC',
    'LUNA', 'LUNC', 'MAGIC', 'MANA', 'MASK', 'MATIC', 'MC', 'MINA', 'MKR', 'MOVR',
    'MXC', 'NEAR', 'NEO', 'NEXO', 'NMR', 'NOW', 'NULS', 'OCEAN', 'OGN', 'OMG',
    'ONE', 'ONT', 'OP', 'ORBS', 'OXT', 'PAXG', 'PEOPLE', 'PEPE', 'PERP', 'PHB',
    'PIVX', 'PLAY', 'POLS', 'POLY', 'POND', 'POWR', 'PYR', 'QI', 'QTUM', 'QUICK',
    'RAD', 'RARE', 'RAY', 'REEF', 'REN', 'REQ', 'RLC', 'RNDR', 'ROSE', 'RPL',
    'RSR', 'RUNE', 'RVN', 'SAND', 'SC', 'SCRT', 'SFP', 'SHIB', 'SKL', 'SLP',
    'SNX', 'SOL', 'SPELL', 'SRM', 'STEEM', 'STG', 'STORJ', 'STPT', 'STRAX', 'STRK',
    'STX', 'SUI', 'SUN', 'SUSHI', 'SWEAT', 'SXP', 'SYN', 'T', 'TIA', 'TLM',
    'TOMO', 'TON', 'TRB', 'TRX', 'TUSD', 'TWT', 'UMA', 'UNFI', 'UNI', 'USDC',
    'USDD', 'USDP', 'USDT', 'VET', 'VGX', 'VTHO', 'WAVES', 'WAXP', 'WBTC', 'WIN',
    'WMT', 'WOO', 'XCH', 'XEC', 'XEM', 'XLM', 'XMR', 'XNO', 'XRP', 'XTZ',
    'XVG', 'XVS', 'YFI', 'YFII', 'ZEC', 'ZEN', 'ZIL', 'ZRX'
  ]..sort();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Grab the active workspace context theme parameters (Matches Dashboard design rules)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF111622) : Colors.grey[100]!;
    const accentColor = Color(0xFF10B981); // Brand Green
    final primaryButtonColor = isDark ? Colors.purpleAccent : const Color(0xFF8B5CF6);

    // Inner element adjustments for light mode readability depth
    final elementBgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final secondaryLabelColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return BlocProvider(
      create: (_) => CryptoSwapBloc(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            'Swap Balances',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: isDark ? const Color(0xFF111622) : Colors.white,
          elevation: 0,
          shape: isDark
              ? null
              : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
          iconTheme: IconThemeData(color: textColor),
        ),
        body: BlocConsumer<CryptoSwapBloc, CryptoSwapState>(
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Swap order transmitted into settlement queue successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
              _amountController.clear();
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator(color: primaryButtonColor));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Instantly exchange value between your traditional Fiat core assets and your Web3 Smart Wallets securely.',
                    style: TextStyle(color: secondaryLabelColor, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 1. "FROM" SOURCE MODULE ROW CARD (WITH DROPDOWN)
                  // ==========================================
                  _buildInputBox(
                    context,
                    title: 'From (Source Asset)',
                    isFiat: state.isFiatToCrypto,
                    selectedValue: state.isFiatToCrypto ? state.selectedFiat : state.selectedCrypto,
                    options: state.isFiatToCrypto ? _fiatCurrencies : _cryptoCurrencies,
                    icon: state.isFiatToCrypto ? Icons.account_balance : Icons.currency_bitcoin,
                    iconColor: state.isFiatToCrypto ? Colors.blueAccent : accentColor,
                    textColor: textColor,
                    cardColor: cardColor,
                    elementBgColor: elementBgColor,
                    secondaryLabelColor: secondaryLabelColor,
                    onAssetChanged: (newValue) {
                      if (state.isFiatToCrypto) {
                        context.read<CryptoSwapBloc>().add(ChangeFiatCurrency(newFiat: newValue));
                      } else {
                        context.read<CryptoSwapBloc>().add(ChangeCryptoCurrency(newCrypto: newValue));
                      }
                    },
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        context.read<CryptoSwapBloc>().add(CalculateSwapAmounts(inputAmount: parsed));
                      },
                    ),
                  ),

                  // ==========================================
                  // DIRECTION SWITCHER TOGGLE ICON BUTTON
                  // ==========================================
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _amountController.clear();
                        context.read<CryptoSwapBloc>().add(ToggleSwapDirection());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: elementBgColor,
                          shape: BoxShape.circle,
                          border: isDark ? null : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Icon(Icons.swap_vert, color: primaryButtonColor, size: 26),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 2. "TO" TARGET MODULE ROW CARD (WITH DROPDOWN)
                  // ==========================================
                  _buildInputBox(
                    context,
                    title: 'To (Destination Target Asset)',
                    isFiat: !state.isFiatToCrypto,
                    selectedValue: !state.isFiatToCrypto ? state.selectedFiat : state.selectedCrypto,
                    options: !state.isFiatToCrypto ? _fiatCurrencies : _cryptoCurrencies,
                    icon: !state.isFiatToCrypto ? Icons.account_balance : Icons.currency_bitcoin,
                    iconColor: !state.isFiatToCrypto ? Colors.blueAccent : accentColor,
                    textColor: textColor,
                    cardColor: cardColor,
                    elementBgColor: elementBgColor,
                    secondaryLabelColor: secondaryLabelColor,
                    onAssetChanged: (newValue) {
                      if (!state.isFiatToCrypto) {
                        context.read<CryptoSwapBloc>().add(ChangeFiatCurrency(newFiat: newValue));
                      } else {
                        context.read<CryptoSwapBloc>().add(ChangeCryptoCurrency(newCrypto: newValue));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        state.outputAmount > 0 ? state.outputAmount.toStringAsFixed(4) : '0.00',
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 3. MENTOR'S ALGORITHMIC PLATFORM FEE BREAKDOWN
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.05 : 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Exchange SaaS Fee (1%)', style: TextStyle(color: secondaryLabelColor, fontSize: 13)),
                        Text(
                          '\$${state.platformFee.toStringAsFixed(2)}',
                          style: TextStyle(color: primaryButtonColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // EXECUTE CONVERSION BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: isDark ? 0 : 2,
                    ),
                    onPressed: state.inputAmount <= 0
                        ? null
                        : () {
                            context.read<CryptoSwapBloc>().add(
                                  ExecuteSwapTransaction(
                                    targetGrossAmount: state.inputAmount,
                                    isFiatToCrypto: state.isFiatToCrypto,
                                  ),
                                );
                          },
                    child: const Text(
                      'Confirm Exchange Swap',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputBox(
    BuildContext context, {
    required String title,
    required bool isFiat,
    required String selectedValue,
    required List<String> options,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color cardColor,
    required Color elementBgColor,
    required Color? secondaryLabelColor,
    required Function(String) onAssetChanged,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSelection = options.contains(selectedValue) ? selectedValue : options.first;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(color: secondaryLabelColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: child),
              
              // ==========================================
              // CUSTOM DROP DOWN SELECTION ACTION FIELD
              // ==========================================
              Container(
                width: 145, 
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: elementBgColor, 
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeSelection,
                    isExpanded: true,
                    menuMaxHeight: 350, // Strict height cap forcing list scrollability 
                    dropdownColor: isDark ? const Color(0xFF111622) : Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: secondaryLabelColor, size: 20),
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: iconColor, size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$value ${isFiat ? "Wallet" : ""}'.trim(),
                                style: TextStyle(color: textColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onAssetChanged(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}