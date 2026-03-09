import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/domain/services/login_service.dart';

class BbbService {
  BbbService({http.Client? client, LoginService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? LoginService();

  final http.Client _client;
  final LoginService _authService;

  static const String _baseUrl = 'https://eduapi.uztelecom.uz/api/v1/bbb/join/';

  Future<String?> joinPublicMeeting(String meetingId) async {
    final uri = Uri.parse('$_baseUrl$meetingId/public/');
    final response = await _authService.authorizedRequest(
      request: (token) => _client.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Mitingga kirishda xatolik.');
    }

    return _extractJoinUrl(response.body);
  }

  String? _extractJoinUrl(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final data = json['data'];
        if (data is Map<String, dynamic>) {
          return data['join_url']?.toString() ??
              data['url']?.toString() ??
              data['meeting_url']?.toString();
        }
        return json['join_url']?.toString() ??
            json['url']?.toString() ??
            json['meeting_url']?.toString();
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _client.close();
  }
}
