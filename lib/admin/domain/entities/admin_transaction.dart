// lib/features/admin/domain/entities/admin_transaction.dart

class AdminTransaction {
  final String id;
  final String userId;
  final String userEmail;
  final double amount;
  final String currency;
  final String type; // deposit, withdrawal, transfer
  final String status; // pending, completed, failed
  final DateTime createdAt;

  const AdminTransaction({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.createdAt,
  });
}
