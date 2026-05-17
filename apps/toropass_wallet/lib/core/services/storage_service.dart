import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/keys.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main.dart');
});

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;
  static FlutterSecureStorage? _secureStorage;

  void clearAllDataFromDisk() {
    _preferences!.clear();
    _secureStorage!.deleteAll();
  }

  Object? getDataFromDisk(String key) {
    return _preferences!.get(key);
  }

  Future<String?> getRefreshTokenFromDisk() async =>
      await _secureStorage!.read(key: AppKeys.refreshToken);

  void removeDataFromDisk(String key) {
    _preferences!.remove(key);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage?.write(key: AppKeys.refreshToken, value: token);
  }

  Future<void> clearRefreshToken() async {
    await _secureStorage?.delete(key: AppKeys.refreshToken);
  }

  Future<void> saveDataToDisk<T>(String key, T content) async {
    switch (content) {
      case String value:
        await _preferences!.setString(key, value);
        break;

      case int value:
        await _preferences!.setInt(key, value);
        break;

      case bool value:
        await _preferences!.setBool(key, value);
        break;

      case double value:
        await _preferences!.setDouble(key, value);
        break;

      case List<String> value:
        await _preferences!.setStringList(key, value);
        break;

      default:
        throw ArgumentError('Unsupported type');
    }
  }

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService();
    _preferences ??= await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
    return _instance!;
  }
}
