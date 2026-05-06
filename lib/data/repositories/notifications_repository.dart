import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/notifications_remote_data_source.dart';
import 'package:uztelecom/data/models/notification_item.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class NotificationsRepository {
  factory NotificationsRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    return NotificationsRepository._(
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

  NotificationsRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
  }) : _client = client,
       _ownsClient = ownsClient,
       _remote = NotificationsRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final NotificationsRemoteDataSource _remote;

  Future<List<NotificationItem>> fetchNotifications({bool? isRead}) {
    return _remote.fetchNotifications(isRead: isRead);
  }

  Future<void> registerDevice({
    required String platform,
    required String pushToken,
    String clientType = 'mobile',
  }) {
    return _remote.registerDevice(
      platform: platform,
      pushToken: pushToken,
      clientType: clientType,
    );
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
