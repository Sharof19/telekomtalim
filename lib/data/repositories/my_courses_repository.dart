import 'package:http/http.dart' as http;
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/my_courses_remote_data_source.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/models/my_course_item.dart';
import 'package:uztelecom/data/repositories/dashboard_repository.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class MyCoursesRepository {
  factory MyCoursesRepository({
    http.Client? client,
    AuthRepository? authService,
    DashboardRepository? dashboardService,
    ApiClient? apiClient,
    bool? ownsClient,
    bool? ownsDashboardService,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    final resolvedApiClient =
        apiClient ??
        ApiClient(
          client: resolvedClient,
          authorizedRequest: resolvedAuthService.authorizedRequest,
        );
    return MyCoursesRepository._(
      client: resolvedClient,
      ownsClient: ownsClient ?? client == null,
      apiClient: resolvedApiClient,
      dashboardService:
          dashboardService ??
          DashboardRepository(
            client: resolvedClient,
            authService: resolvedAuthService,
            apiClient: resolvedApiClient,
            ownsClient: false,
          ),
      ownsDashboardService: ownsDashboardService ?? dashboardService == null,
    );
  }

  MyCoursesRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
    required DashboardRepository dashboardService,
    required bool ownsDashboardService,
  }) : _client = client,
       _ownsClient = ownsClient,
       _dashboardService = dashboardService,
       _ownsDashboardService = ownsDashboardService,
       _remote = MyCoursesRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final DashboardRepository _dashboardService;
  final bool _ownsDashboardService;
  final MyCoursesRemoteDataSource _remote;

  Future<List<MyCourseItem>> fetchMyCourses() async {
    final items = await _remote.fetchMyCourses();
    return _enrichProgress(items);
  }

  Future<CourseItem> fetchCourseDetail(int id) => _remote.fetchCourseDetail(id);

  Future<List<MyCourseItem>> _enrichProgress(List<MyCourseItem> items) async {
    if (items.isEmpty) return items;
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);
    final startDate = endDate.subtract(const Duration(days: 6));

    try {
      final summary = await _dashboardService.fetchSummary(
        startDate: startDate,
        endDate: endDate,
        days: 7,
      );
      final byId = <int, DashboardCurrentCourse>{};
      final byName = <String, DashboardCurrentCourse>{};

      for (final course in summary.currentCourses) {
        if (course.courseId > 0) {
          byId[course.courseId] = course;
        }
        final normalized = _normalizeTitle(course.courseName);
        if (normalized.isNotEmpty) {
          byName[normalized] = course;
        }
      }

      return items.map((item) {
        final matched =
            byId[item.id] ?? byName[_normalizeTitle(item.title ?? '')];
        if (matched == null) return item;

        return item.copyWith(
          progressPercent: item.progressPercent ?? matched.progressPercent,
          completedActivities:
              item.completedActivities ?? matched.completedActivities,
          totalActivities: item.totalActivities ?? matched.totalActivities,
        );
      }).toList();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to enrich my courses with dashboard progress.',
        error: error,
        stackTrace: stackTrace,
      );
      return items;
    }
  }

  String _normalizeTitle(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  void dispose() {
    if (_ownsDashboardService) {
      _dashboardService.dispose();
    }
    if (_ownsClient) {
      _client.close();
    }
  }
}
