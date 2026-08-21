
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static final SharedPreference _instance = SharedPreference._internal();
  factory SharedPreference() => _instance;
  SharedPreference._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  
  void saveString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  void saveBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  void saveInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  void saveDouble(String key, double value) => _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);

  void saveStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  
  void saveJson(String key, dynamic value) {
    _prefs.setString(key, jsonEncode(value));
  }

  dynamic getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  bool containsKey(String key) => _prefs.containsKey(key);
  
  void removeKey(String key) => _prefs.remove(key);
  
  void clearAll() async {
    await _prefs.clear();
  }
}