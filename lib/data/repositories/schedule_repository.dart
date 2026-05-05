import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/schedule_remote_data_source.dart';
import 'package:uztelecom/data/models/schedule_models.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class ScheduleRepository {
  factory ScheduleRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    return ScheduleRepository._(
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

  ScheduleRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
  }) : _client = client,
       _ownsClient = ownsClient,
       _remote = ScheduleRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final ScheduleRemoteDataSource _remote;

  Future<ScheduleData> fetchSchedule({
    required String startDate,
    required String endDate,
  }) => _remote.fetchSchedule(startDate: startDate, endDate: endDate);

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
