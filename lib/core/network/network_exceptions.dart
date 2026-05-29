// lib/core/network/network_exceptions.dart

import 'package:dio/dio.dart';

/// Centralized Exception Parser that converts raw network errors
/// into clear, user-friendly system messages.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(message: "Connection timed out. Please check your internet server gateway.");
      case DioExceptionType.sendTimeout:
        return NetworkException(message: "Request send timeout. Verify network stability.");
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: "Server response timeout. The database is taking too long to reply.");
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return NetworkException(message: "The network request was intentionally aborted.");
      case DioExceptionType.connectionError:
        return NetworkException(message: "No active internet connection detected. Please verify your mobile data or Wi-Fi connectivity.");
      default:
        return NetworkException(message: "An unexpected network anomaly occurred. Please try again later.");
    }
  }

  static NetworkException _handleBadResponse(Response? response) {
    final int? statusCode = response?.statusCode;
    final dynamic data = response?.data;
    
    // Extract server message if your backend provides one (e.g., {"message": "Invalid transaction PIN"})
    String errorMessage = "Server evaluation mismatch occurred.";
    if (data is Map && data.containsKey('message')) {
      errorMessage = data['message'].toString();
    } else if (data is Map && data.containsKey('error')) {
      errorMessage = data['error'].toString();
    }

    switch (statusCode) {
      case 400:
        return NetworkException(message: "Bad Request: $errorMessage", statusCode: statusCode);
      case 401:
        return NetworkException(message: "Session expired. Please log in again.", statusCode: statusCode);
      case 403:
        return NetworkException(message: "Access Denied: You do not have permission to execute this operation.", statusCode: statusCode);
      case 404:
        return NetworkException(message: "Requested endpoint tracking node could not be found.", statusCode: statusCode);
      case 429:
        return NetworkException(message: "Too many requests. Anti-bot compliance system triggered. Please slow down.", statusCode: statusCode);
      case 500:
        return NetworkException(message: "Internal banking engine malfunction. Our engineers are investigating.", statusCode: statusCode);
      default:
        return NetworkException(message: "Communication Error ($statusCode): $errorMessage", statusCode: statusCode);
    }
  }

  @override
  String toString() => message;
}