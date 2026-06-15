class CryptoPaymentModel {
  final String paymentId;
  final String paymentStatus;
  final String payAddress;
  final double priceAmount;
  final String priceCurrency;
  final String payCurrency;

  CryptoPaymentModel({
    required this.paymentId,
    required this.paymentStatus,
    required this.payAddress,
    required this.priceAmount,
    required this.priceCurrency,
    required this.payCurrency,
  });

  factory CryptoPaymentModel.fromJson(Map<String, dynamic> json) {
    return CryptoPaymentModel(
      paymentId: json['payment_id']?.toString() ?? '',
      paymentStatus: json['payment_status'] ?? 'waiting',
      payAddress: json['pay_address'] ?? '',
      priceAmount: (json['price_amount'] as num?)?.toDouble() ?? 0.0,
      priceCurrency: json['price_currency'] ?? 'usd',
      payCurrency: json['pay_currency'] ?? '',
    );
  }
}