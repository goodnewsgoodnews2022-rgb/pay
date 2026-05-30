import 'package:equatable/equatable.dart';

class CryptoAssetModel extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final double balance;
  final double currentPriceUsd;

  const CryptoAssetModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.balance,
    required this.currentPriceUsd,
  });

  /// Computed property to handle the fiat market value math inside the model layer safely
  double get totalFiatValue => balance * currentPriceUsd;

  /// Safe Factory Constructor to convert incoming Map/JSON payloads from database endpoints
  factory CryptoAssetModel.fromJson(Map<String, dynamic> json) {
    return CryptoAssetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      balance: (json['balance'] as num).toDouble(),
      currentPriceUsd: (json['current_price_usd'] as num).toDouble(),
    );
  }

  /// Helper method to transform the data structure back into a JSON format for server synchronization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'balance': balance,
      'current_price_usd': currentPriceUsd,
    };
  }

  @override
  List<Object?> get props => [id, name, symbol, balance, currentPriceUsd];
}