import 'package:flutter/material.dart';
import '../../data/models/crypto_asset_model.dart';
import '../widgets/address_frame.dart';
import '../widgets/crypto_asset_tile.dart';

class CryptoWalletScreen extends StatelessWidget {
  const CryptoWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated list parsing using your new immutable CryptoAssetModel structure
    const List<CryptoAssetModel> userAssets = [
      CryptoAssetModel(
        id: '1',
        name: 'Ethereum',
        symbol: 'ETH',
        balance: 1.4502,
        currentPriceUsd: 3344.50,
      ),
      CryptoAssetModel(
        id: '2',
        name: 'USD Coin',
        symbol: 'USDC',
        balance: 2500.00,
        currentPriceUsd: 1.00,
      ),
      CryptoAssetModel(
        id: '3',
        name: 'Solana',
        symbol: 'SOL',
        balance: 18.75,
        currentPriceUsd: 102.42,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Web3 Assets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Center(
                child: AddressFrame(
                  fullAddress: '0x7a89c31415926cdeba34b2f1122a90b8f3914b2f',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'CONNECTED CHAINS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: userAssets.length,
                  itemBuilder: (context, index) {
                    final asset = userAssets[index];
                    
                    // Choosing display context icons based on asset symbols safely
                    IconData displayIcon;
                    switch (asset.symbol) {
                      case 'ETH':
                        displayIcon = Icons.currency_bitcoin;
                        break;
                      case 'USDC':
                        displayIcon = Icons.monetization_on;
                        break;
                      default:
                        displayIcon = Icons.token;
                    }

                    return CryptoAssetTile(
                      tokenName: asset.name,
                      tokenSymbol: asset.symbol,
                      cryptoBalance: asset.balance,
                      fiatValue: asset.totalFiatValue, // Automatically utilizes model math calculations
                      tokenIcon: displayIcon,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}