import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FaceIdService {
  FaceIdService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _expiryKey = 'access_token_expiry';

  Future<void> verifyFace({
    required String studentId,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api-dars.tsue.uz/api/v1/face-login/'),
    );

    request.fields['student_id_number'] = studentId;
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );
    request.headers['Accept'] = 'application/json';

    final response = await _client.send(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _handleAuthResponse(responseBody);
      return;
    }

    final serverMessage = _extractMessage(responseBody);
    throw Exception(
      serverMessage ?? 'Server error: ${response.statusCode}',
    );
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

  Future<String?> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(_refreshKey);
    if (refresh == null) return null;

    final response = await _client.post(
      Uri.parse('https://api-dars.tsue.uz/api/v1/face-login/refresh/'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _handleAuthResponse(response.body);
      return prefs.getString(_accessKey);
    }

    throw Exception(
      _extractMessage(response.body) ?? 'Tokenni yangilashda xatolik.',
    );
  }

  Future<void> _handleAuthResponse(String body) async {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    if (data == null) return;

    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    if (access == null || refresh == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);

    final exp = _decodeExpiry(access);
    if (exp != null) {
      await prefs.setInt(_expiryKey, exp);
    }
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
          final idx = message.indexOf('(');
          return idx > 0 ? message.substring(0, idx).trim() : message;
        }
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _client.close();
  }
}
