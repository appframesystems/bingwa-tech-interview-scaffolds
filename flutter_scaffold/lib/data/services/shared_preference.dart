import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SharedPreferenceService {
  final _storage = const FlutterSecureStorage();

  // Save string
  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Get string
  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  // Save object
  Future<void> saveObject(String key, dynamic value) async {
    await _storage.write(key: key, value: jsonEncode(value));
  }

  // Get object
  Future<dynamic> getObject(String key) async {
    final value = await _storage.read(key: key);
    if (value != null) {
      return jsonDecode(value);
    }
    return null;
  }

  // Get JSON
  Future<List<dynamic>?> getJson(String key) async {
    final value = await getString(key);
    if (value != null) {
      return jsonDecode(value) as List<dynamic>;
    }
    return null;
  }

  // Save JSON
  Future<void> saveJson(String key, List<dynamic> value) async {
    await saveString(key, jsonEncode(value));
  }

  // Delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Delete all
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}