import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const accessKey = 'auth_access_token';
  static const refreshKey = 'auth_refresh_token';
  static const expiryKey = 'auth_access_token_expiry';

  final FlutterSecureStorage _secureStorage;
  Future<void>? _migration;

  Future<String?> getAccessToken() async {
    await _ensureLegacyPrefsMigrated();
    return _secureStorage.read(key: accessKey);
  }

  Future<String?> getRefreshToken() async {
    await _ensureLegacyPrefsMigrated();
    return _secureStorage.read(key: refreshKey);
  }

  Future<int?> getAccessTokenExpiry() async {
    await _ensureLegacyPrefsMigrated();
    final value = await _secureStorage.read(key: expiryKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    int? expiry,
  }) async {
    await _ensureLegacyPrefsMigrated();
    await _secureStorage.write(key: accessKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(key: refreshKey, value: refreshToken);
    }
    if (expiry != null) {
      await _secureStorage.write(key: expiryKey, value: expiry.toString());
    }
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: accessKey);
    await _secureStorage.delete(key: refreshKey);
    await _secureStorage.delete(key: expiryKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessKey);
    await prefs.remove(refreshKey);
    await prefs.remove(expiryKey);
  }

  Future<void> _ensureLegacyPrefsMigrated() {
    return _migration ??= _migrateLegacyPrefs();
  }

  Future<void> _migrateLegacyPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(accessKey);
    final refresh = prefs.getString(refreshKey);
    final expiry = prefs.getInt(expiryKey);

    if (access != null && access.isNotEmpty) {
      await _secureStorage.write(key: accessKey, value: access);
    }
    if (refresh != null && refresh.isNotEmpty) {
      await _secureStorage.write(key: refreshKey, value: refresh);
    }
    if (expiry != null) {
      await _secureStorage.write(key: expiryKey, value: expiry.toString());
    }

    await prefs.remove(accessKey);
    await prefs.remove(refreshKey);
    await prefs.remove(expiryKey);
  }
}
