import 'package:dio/dio.dart';
import '../models/crypto_payment_model.dart';

class CryptoApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-sandbox.nowpayments.io/v1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final String _apiKey = 'N8BR5V4-9X54A57-GT8QD1Z-P4GPCHX';

  /// Generates a unique deposit address for USDT on BEP20 or TRC20
  /// [amount] is the USD equivalent value
  /// [currency] must be either 'usdtbsc' (BEP20) or 'usdttrx' (TRC20)
  Future<CryptoPaymentModel> createDepositInvoice({
    required double amount,
    required String currency, // 'usdtbsc' or 'usdttrx'
  }) async {
    try {
      final response = await _dio.post(
        'payment',
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'price_amount': amount,
          'price_currency': 'usd',
          'pay_currency': currency,
          'order_description': 'SaaS Wallet Deposit Check-in',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CryptoPaymentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to generate address: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Network Error: $errorMsg');
    }
  }
}