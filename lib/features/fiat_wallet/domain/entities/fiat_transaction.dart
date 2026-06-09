class FiatTransaction {
  final String id;
  final String walletId;
  final double amount;
  final String type; // deposit, withdrawal, transfer
  final String reference;
  final String status; // pending, completed, failed
  final DateTime? completedAt;
  final DateTime createdAt;

  const FiatTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.reference,
    required this.status,
    this.completedAt,
    required this.createdAt,
  });
}
