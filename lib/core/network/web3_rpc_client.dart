// lib/core/network/web3_rpc_client.dart

// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../../app/config/environment.dart';

/// Centralized Provider for Web3 Engine Node connectivity.
/// Establishes the real-time communication pipeline with EVM blockchain networks
/// via secure JSON-RPC endpoint streams.
class Web3RpcClient {
  late Web3Client _web3client;
  late http.Client _httpClient;
  bool _isConfigured = false;

  // Private internal constructor to enforce the Singleton design pattern
  Web3RpcClient._internal();

  /// Single, shared global gateway instance for all Web3 network integrations
  static final Web3RpcClient instance = Web3RpcClient._internal();

  /// Configures the active connection pool to the blockchain node gateway.
  /// Automatically called during initialization or when switching network chains.
  void configure({String? customRpcUrl}) {
    // Fall back to our secure Environment configuration variable if no custom track is passed
    final String targetRpcUrl = customRpcUrl ?? Environment.mainnetRpcUrl;

    if (targetRpcUrl.contains('placeholder')) {
      print('⚠️ WARNING: Web3 RPC node is initialized with a placeholder token. On-chain queries will fail.');
    }

    try {
      _httpClient = http.Client();
      _web3client = Web3Client(targetRpcUrl, _httpClient);
      _isConfigured = true;
      
      print('⛓️ [WEB3-INFRA] RPC Node successfully attached to: $targetRpcUrl');
    } catch (e) {
      print('❌ [WEB3-INFRA-ERROR] Failed to instantiate standard Web3 JSON-RPC connection client: $e');
      _isConfigured = false;
      rethrow;
    }
  }

  /// Exposes the operational Web3 engine client driver.
  /// Your team members will use this instance to perform on-chain interactions:
  /// e.g., `Web3RpcClient.instance.client.getBalance(ethereumAddress);`
  Web3Client get client {
    if (!_isConfigured) {
      // Auto-configure with defaults if accessed before an explicit call
      configure();
    }
    return _web3client;
  }

  /// Helper to safely fetch the active network chain ID (e.g., 1 for Ethereum Mainnet, 11155111 for Sepolia)
  Future<BigInt> getActiveNetworkChainId() async {
    try {
      return await client.getChainId();
    } catch (e) {
      print('❌ [WEB3-INFRA-ERROR] Failed to retrieve on-chain network ID parameters: $e');
      return Future.value(BigInt.from(-1));
    }
  }

  /// Cleanly closes persistent keep-alive network sockets during app termination sequences
  void dispose() {
    if (_isConfigured) {
      _httpClient.close();
      _isConfigured = false;
      print('🔒 [WEB3-INFRA] Connected blockchain node channels closed cleanly.');
    }
  }
}