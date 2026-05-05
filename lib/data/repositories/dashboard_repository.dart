import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/dashboard_remote_data_source.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class DashboardRepository {
  factory DashboardRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    return DashboardRepository._(
      client: resolvedClient,
      ownsClient: ownsClient ?? client == null,
      apiClient:
          apiClient ??
          ApiClient(
            client: resolvedClient,
            authorizedRequest: resolvedAuthService.authorizedRequest,
          ),
    );
  }

  DashboardRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
  }) : _client = client,
       _ownsClient = ownsClient,
       _remote = DashboardRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final DashboardRemoteDataSource _remote;

  Future<DashboardProgress> fetchProgress({required int courseId}) =>
      _remote.fetchProgress(courseId: courseId);

  Future<DashboardSummary> fetchSummary({
    required DateTime startDate,
    required DateTime endDate,
    int days = 7,
  }) =>
      _remote.fetchSummary(startDate: startDate, endDate: endDate, days: days);

  Future<DashboardTimeStats> fetchTimeStats({
    required DateTime startDate,
    required DateTime endDate,
    required int courseId,
  }) => _remote.fetchTimeStats(
    startDate: startDate,
    endDate: endDate,
    courseId: courseId,
  );

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
