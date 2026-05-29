// lib/core/network/api_client.dart

// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'network_exceptions.dart';

/// Enterprise-grade Network Client wrapper utilizing the Dio library.
/// Provides standardized connection timeout protocols, automated console tracing headers,
/// and systematic response modeling.
class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl}) : _dio = Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15) // 15s limit to protect user flow
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 15)
      ..responseType = ResponseType.json;

    // Attach our custom telemetry monitoring middleware
    _dio.interceptors.add(_NetworkLoggingInterceptor());
  }

  /// Exposed secure client instance for custom feature implementations
  Dio get client => _dio;

  /// Standardized GET Request Engine
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Standardized POST Request Engine
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}

// ====================================================================
// INTERNAL NETWORK TELEMETRY LOGGER (Interceptor)
// ====================================================================
class _NetworkLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 [NET-REQ] [${options.method}] -> Path: ${options.path}');
    print('📦 Headers: ${options.headers}');
    if (options.data != null) print('📄 Body payload: ${options.data}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [NET-RES] [${response.statusCode}] <- From: ${response.requestOptions.path}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ [NET-ERR] [${err.response?.statusCode}] <- Error: ${err.message}');
    return super.onError(err, handler);
  }
}