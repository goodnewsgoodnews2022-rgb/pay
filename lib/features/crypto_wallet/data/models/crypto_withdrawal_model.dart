class CryptoWithdrawalModel {
  final String id;
  final String address;
  final String currency;
  final double amount;
  final String status;

  CryptoWithdrawalModel({
    required this.id,
    required this.address,
    required this.currency,
    required this.amount,
    required this.status,
  });

  factory CryptoWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return CryptoWithdrawalModel(
      id: json['id']?.toString() ?? '',
      address: json['address'] ?? '',
      currency: json['currency'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'processing',
    );
  }
}