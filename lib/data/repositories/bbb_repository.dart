import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class BbbRepository {
  BbbRepository({http.Client? client, AuthRepository? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthRepository();

  final http.Client _client;
  final AuthRepository _authService;

  Future<String?> joinPublicMeeting(String meetingId) async {
    final uri = AppEndpoints.bbbJoin(meetingId);
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
