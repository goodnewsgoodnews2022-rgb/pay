class FiatWalletModel {
  final double ngnBalance;
  final double usdBalance;
  final double eurBalance;

  const FiatWalletModel({
    this.ngnBalance = 0.0,
    this.usdBalance = 0.0,
    this.eurBalance = 0.0,
  });

  // Factory map converting raw database map structures from Supabase
  factory FiatWalletModel.fromMap(Map<String, dynamic> data) {
    return FiatWalletModel(
      ngnBalance: (data['ngn_balance'] ?? 0.0).toDouble(),
      usdBalance: (data['usd_balance'] ?? 0.0).toDouble(),
      eurBalance: (data['eur_balance'] ?? 0.0).toDouble(),
    );
  }

  // Multiplies raw currency entries against baseline mock market index vectors
  // To aggregate a dynamic overall portfolio net worth value automatically.
  double calculateTotalInUSD({
    double ngnToUsdRate = 0.00067, // Example market vectors
    double eurToUsdRate = 1.08,
  }) {
    return usdBalance + (ngnBalance * ngnToUsdRate) + (eurBalance * eurToUsdRate);
  }
}