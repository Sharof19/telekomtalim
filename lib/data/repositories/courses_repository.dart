import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/courses_remote_data_source.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class CoursesRepository {
  factory CoursesRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    return CoursesRepository._(
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

  CoursesRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
  }) : _client = client,
       _ownsClient = ownsClient,
       _remote = CoursesRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final CoursesRemoteDataSource _remote;

  Future<List<CourseItem>> fetchCourses() => _remote.fetchCourses();

  Future<CourseItem> fetchCourseDetail(int id) => _remote.fetchCourseDetail(id);

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
