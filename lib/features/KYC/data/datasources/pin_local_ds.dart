import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PinLocalDataSource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _pinKey = 'user_pin';

  Future<void> savePin(String pin) async {
    // Simple hashing (optional: use a proper KDF)
    final hashed = base64.encode(utf8.encode(pin));
    await _storage.write(key: _pinKey, value: hashed);
  }

  Future<String?> getHashedPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }
}
