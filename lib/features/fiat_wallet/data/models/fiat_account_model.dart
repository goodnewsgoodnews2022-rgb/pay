import 'package:fintech/features/fiat_wallet/domain/entities/fiat_account.dart';

class FiatAccountModel extends FiatAccount {
  const FiatAccountModel({
    required super.id,
    required super.userId,
    required super.currency,
    required super.balance,
    super.accountNumber,
    super.bankName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FiatAccountModel.fromJson(Map<String, dynamic> json) {
    return FiatAccountModel(
      id: json['id'],
      userId: json['user_id'],
      currency: json['currency'],
      balance: (json['balance'] as num).toDouble(),
      accountNumber: json['account_number'],
      bankName: json['bank_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'currency': currency,
      'balance': balance,
      'account_number': accountNumber,
      'bank_name': bankName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
