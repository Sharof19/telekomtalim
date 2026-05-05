import 'dart:convert';

import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';

class BbbRemoteDataSource {
  const BbbRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String?> joinPublicMeeting(String meetingId) async {
    final uri = AppEndpoints.bbbJoin(meetingId);
    final response = await _apiClient.post(uri, authorized: true);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiClient.failureFromResponse(
        response,
        fallbackMessage: 'Mitingga kirishda xatolik.',
      );
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
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to parse BBB join URL response.',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }
}
