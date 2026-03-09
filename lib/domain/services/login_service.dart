import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  LoginService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static Future<String?>? _ongoingRefresh;

  static const String _loginUrl = 'https://eduapi.uztelecom.uz/api/v1/login/';
  static const String _verifyUrl =
      'https://eduapi.uztelecom.uz/api/v1/verify-code/';
  static const String _resendUrl =
      'https://eduapi.uztelecom.uz/api/v1/resend-code/';
  static const String _refreshUrl =
      'https://eduapi.uztelecom.uz/api/v1/refresh-token/';
  static const String _logoutUrl =
      'https://eduapi.uztelecom.uz/api/v1/logout/';

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _expiryKey = 'auth_access_token_expiry';
  static const _authErrorCodes = {401, 403, 498};

  Future<void> requestLogin({
    required String login,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(_loginUrl),
      headers: const {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(_extractMessage(response.body) ?? 'Login xatosi.');
  }

  Future<void> verifyCode({
    required String login,
    required String code,
  }) async {
    final response = await _client.post(
      Uri.parse(_verifyUrl),
      headers: const {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login, 'code': code}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _handleAuthResponse(response.body);
      return;
    }

    throw Exception(_extractMessage(response.body) ?? 'Kod tasdiqlanmadi.');
  }

  Future<void> resendCode({required String login}) async {
    final response = await _client.post(
      Uri.parse(_resendUrl),
      headers: const {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(_extractMessage(response.body) ?? 'Kod yuborilmadi.');
  }

  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessKey);
    final expiry = prefs.getInt(_expiryKey);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (access != null && expiry != null && expiry - now > 60) {
      return access;
    }

    return _refreshAccessToken();
  }

  Future<http.Response> authorizedRequest({
    required Future<http.Response> Function(String token) request,
    bool retryOnAuthError = true,
  }) async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw Exception('Token topilmadi. Iltimos, qayta kiring.');
    }

    var response = await request(token);
    final shouldRefresh = _authErrorCodes.contains(response.statusCode) ||
        _isTokenInvalidResponse(response.body);
    if (retryOnAuthError && shouldRefresh) {
      try {
        final refreshed = await _refreshAccessToken();
        if (refreshed == null || refreshed.isEmpty) {
          await _clearTokens();
          throw Exception('Token eskirgan. Iltimos, qayta kiring.');
        }
        response = await request(refreshed);
      } catch (_) {
        await _clearTokens();
        rethrow;
      }
    }

    return response;
  }

  bool _isTokenInvalidResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return false;

      final code = decoded['code']?.toString().toLowerCase();
      if (code == 'token_not_valid') return true;

      final detail = decoded['detail']?.toString().toLowerCase() ?? '';
      if (detail.contains('token') &&
          (detail.contains('expired') || detail.contains('not valid'))) {
        return true;
      }

      final messages = decoded['messages'];
      if (messages is List) {
        for (final item in messages) {
          if (item is! Map<String, dynamic>) continue;
          final message = item['message']?.toString().toLowerCase() ?? '';
          if (message.contains('token') &&
              (message.contains('expired') ||
                  message.contains('not valid') ||
                  message.contains('invalid'))) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(_refreshKey);
    final access = prefs.getString(_accessKey);

    if (refresh != null && refresh.isNotEmpty && access != null && access.isNotEmpty) {
      final response = await _client.post(
        Uri.parse(_logoutUrl),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        },
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractMessage(response.body) ?? 'Logout xatosi.');
      }
    }

    await _clearTokens();
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_expiryKey);
  }

  Future<String?> _refreshAccessToken() async {
    final inFlight = _ongoingRefresh;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _refreshAccessTokenInternal();
    _ongoingRefresh = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_ongoingRefresh, refreshFuture)) {
        _ongoingRefresh = null;
      }
    }
  }

  Future<String?> _refreshAccessTokenInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(_refreshKey);
    if (refresh == null) return null;

    final response = await _client.post(
      Uri.parse(_refreshUrl),
      headers: const {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final access = await _handleAuthResponse(response.body);
      return access ?? prefs.getString(_accessKey);
    }

    throw Exception(
      _extractMessage(response.body) ?? 'Tokenni yangilashda xatolik.',
    );
  }

  Future<String?> _handleAuthResponse(String body) async {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final data = decoded['data'] is Map<String, dynamic>
        ? decoded['data'] as Map<String, dynamic>
        : decoded;

    final access = data['access']?.toString();
    final refresh = data['refresh']?.toString();
    if (access == null || access.isEmpty) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    if (refresh != null && refresh.isNotEmpty) {
      await prefs.setString(_refreshKey, refresh);
    }

    final exp = _decodeExpiry(access);
    if (exp != null) {
      await prefs.setInt(_expiryKey, exp);
    }
    return access;
  }

  int? _decodeExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)))
          as Map<String, dynamic>;
      return payload['exp'] as int?;
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final message = json['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final detail = json['detail']?.toString();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _client.close();
  }
}
