import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DashboardProgress> fetchProgress({required int courseId}) async {
    final response = await _apiClient.get(
      AppEndpoints.dashboardProgress().replace(
        queryParameters: {'course_id': '$courseId'},
      ),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Progress ma\'lumotini olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = ApiClient.dataMap(body);
    return DashboardProgress.fromJson(data);
  }

  Future<DashboardSummary> fetchSummary({
    required DateTime startDate,
    required DateTime endDate,
    int days = 7,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.dashboardSummary().replace(
        queryParameters: {
          'start_date': _fmtDate(startDate),
          'end_date': _fmtDate(endDate),
          'days': '$days',
        },
      ),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Dashboard statistikani olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = ApiClient.dataMap(body);
    return DashboardSummary.fromJson(data);
  }

  Future<DashboardTimeStats> fetchTimeStats({
    required DateTime startDate,
    required DateTime endDate,
    required int courseId,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.dashboardTimeStats().replace(
        queryParameters: {
          'start_date': _fmtDate(startDate),
          'end_date': _fmtDate(endDate),
          'course_id': '$courseId',
        },
      ),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Vaqt statistikasini olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = ApiClient.dataMap(body);
    return DashboardTimeStats.fromJson(data);
  }

  String _fmtDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
