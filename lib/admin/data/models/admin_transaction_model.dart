// lib/features/admin/data/models/admin_transaction_model.dart

import '../../domain/entities/admin_transaction.dart';

class AdminTransactionModel extends AdminTransaction {
  const AdminTransactionModel({
    required super.id,
    required super.userId,
    required super.userEmail,
    required super.amount,
    required super.currency,
    required super.type,
    required super.status,
    required super.createdAt,
  });

  factory AdminTransactionModel.fromJson(Map<String, dynamic> json) {
    return AdminTransactionModel(
      id: json['id'],
      userId: json['user_id'],
      userEmail: json['user_email'] ?? 'unknown@example.com',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      type: json['type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
