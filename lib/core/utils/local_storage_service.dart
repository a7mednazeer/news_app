import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] so feature repositories never
/// touch the platform API directly. Centralizing (de)serialization here
/// keeps StorageKeys usage consistent and makes the underlying persistence
/// mechanism swappable (e.g. to Hive/Isar) without touching call sites.
class LocalStorageService {
  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  double getDouble(String key, {double defaultValue = 1.0}) =>
      _prefs.getDouble(key) ?? defaultValue;

  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);
}
