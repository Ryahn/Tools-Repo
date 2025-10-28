import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for storing sensitive data like tokens
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Store a value with the given key
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      log('Error writing to secure storage: $e', error: e);
      rethrow;
    }
  }

  /// Read a value by key
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      log('Error reading from secure storage: $e', error: e);
      rethrow;
    }
  }

  /// Delete a value by key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      log('Error deleting from secure storage: $e', error: e);
      rethrow;
    }
  }

  /// Delete all stored values
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      log('Error deleting all from secure storage: $e', error: e);
      rethrow;
    }
  }

  /// Read all values
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      log('Error reading all from secure storage: $e', error: e);
      rethrow;
    }
  }
}
