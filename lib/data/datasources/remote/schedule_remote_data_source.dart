import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/schedule_models.dart';

class ScheduleRemoteDataSource {
  const ScheduleRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ScheduleData> fetchSchedule({
    required String startDate,
    required String endDate,
  }) async {
    final uri = AppEndpoints.listenerSchedule(
      startDate: startDate,
      endDate: endDate,
    );

    final response = await _apiClient.get(uri, authorized: true);
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Jadvalni olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ParsingFailure('Jadval topilmadi.');
    }

    return ScheduleData.fromJson(data);
  }
}
