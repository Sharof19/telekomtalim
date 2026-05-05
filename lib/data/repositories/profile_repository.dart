import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/local/profile_local_data_source.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/profile_remote_data_source.dart';
import 'package:uztelecom/data/models/profile_models.dart';

import 'auth_repository.dart';

class ProfileRepository {
  factory ProfileRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    final resolvedLocal = ProfileLocalDataSource();
    return ProfileRepository._(
      client: resolvedClient,
      ownsClient: ownsClient ?? client == null,
      apiClient:
          apiClient ??
          ApiClient(
            client: resolvedClient,
            authorizedRequest: resolvedAuthService.authorizedRequest,
          ),
      local: resolvedLocal,
    );
  }

  ProfileRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
    required ProfileLocalDataSource local,
  }) : _client = client,
       _ownsClient = ownsClient,
       _local = local,
       _remote = ProfileRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final ProfileLocalDataSource _local;
  final ProfileRemoteDataSource _remote;

  Future<ProfileInfo?> getCachedProfile() => _local.getCachedProfile();

  Future<void> clearCachedProfile() => _local.clearCachedProfile();

  Future<ProfileInfo> fetchProfile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await getCachedProfile();
      if (cached != null) return cached;
    }
    final profile = await _remote.fetchProfile();
    await _local.saveProfile(profile);
    return profile;
  }

  Future<EditableProfileInfo> fetchEditableProfile() =>
      _remote.fetchEditableProfile();

  Future<void> updateProfile(EditableProfileInfo profile) async {
    await _remote.updateProfile(profile);
    await _local.updateCachedEditableProfile(profile);
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
