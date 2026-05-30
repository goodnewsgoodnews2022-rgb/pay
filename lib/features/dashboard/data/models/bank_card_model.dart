import 'package:equatable/equatable.dart';

class BankCardModel extends Equatable {
  final String id;
  final String cardHolderName;
  final String lastFourDigits;
  final String cardExpiry;
  final double balance;
  final String cardType; // e.g., 'Visa', 'Mastercard'

  const BankCardModel({
    required this.id,
    required this.cardHolderName,
    required this.lastFourDigits,
    required this.cardExpiry,
    required this.balance,
    required this.cardType,
  });

  /// Safe Factory Constructor to map incoming database records into clean Dart objects
  factory BankCardModel.fromJson(Map<String, dynamic> json) {
    return BankCardModel(
      id: json['id'] as String,
      cardHolderName: json['card_holder_name'] as String,
      lastFourDigits: json['last_four_digits'] as String,
      cardExpiry: json['card_expiry'] as String,
      balance: (json['balance'] as num).toDouble(),
      cardType: json['card_type'] as String,
    );
  }

  /// Transforms the model structure into a JSON map for backend sync operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_holder_name': cardHolderName,
      'last_four_digits': lastFourDigits,
      'card_expiry': cardExpiry,
      'balance': balance,
      'card_type': cardType,
    };
  }

  @override
  List<Object?> get props => [id, cardHolderName, lastFourDigits, cardExpiry, balance, cardType];
}