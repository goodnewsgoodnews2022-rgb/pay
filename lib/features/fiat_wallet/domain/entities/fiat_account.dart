class FiatAccount {
  final String id;
  final String userId;
  final String currency;
  final double balance;
  final String? accountNumber;
  final String? bankName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FiatAccount({
    required this.id,
    required this.userId,
    required this.currency,
    required this.balance,
    this.accountNumber,
    this.bankName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiatAccount &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
