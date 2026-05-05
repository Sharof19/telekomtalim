import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/bbb_remote_data_source.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class BbbRepository {
  factory BbbRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    return BbbRepository._(
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

  BbbRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
  }) : _client = client,
       _ownsClient = ownsClient,
       _remote = BbbRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final BbbRemoteDataSource _remote;

  Future<String?> joinPublicMeeting(String meetingId) =>
      _remote.joinPublicMeeting(meetingId);

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
