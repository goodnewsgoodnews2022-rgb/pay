import 'package:fintech/features/fiat_wallet/domain/entities/fiat_transaction.dart';

class FiatTransactionModel extends FiatTransaction {
  const FiatTransactionModel({
    required super.id,
    required super.walletId,
    required super.amount,
    required super.type,
    required super.reference,
    required super.status,
    super.completedAt,
    required super.createdAt,
  });

  factory FiatTransactionModel.fromJson(Map<String, dynamic> json) {
    return FiatTransactionModel(
      id: json['id'],
      walletId: json['wallet_id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      reference: json['reference'],
      status: json['status'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'amount': amount,
      'type': type,
      'reference': reference,
      'status': status,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
