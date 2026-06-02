import 'package:flutter/material.dart';
import '../../data/models/bank_card_model.dart';
import '../widgets/portfolio_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated mock account profile parsed from your model schema
    const BankCardModel primaryAccount = BankCardModel(
      id: 'fiat-card-01',
      cardHolderName: 'LAWRENCE',
      lastFourDigits: '4321',
      cardExpiry: '12/29',
      balance: 14500.50,
      cardType: 'Visa',
    );

    return Scaffold(
      backgroundColor: Colors.black, // Dark mode canvas baseline
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Financial Hub',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // REMOVED 'const' from here so it can read the model balance dynamically
                PortfolioCard(
                  totalBalance: primaryAccount.balance,
                  cryptoAddress: '0x7a89...4b2f',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}