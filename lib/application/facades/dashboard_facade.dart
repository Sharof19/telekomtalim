import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/data/models/main_dashboard_data.dart';
import 'package:uztelecom/data/models/my_course_item.dart';
import 'package:uztelecom/data/repositories/dashboard_repository.dart';
import 'package:uztelecom/data/repositories/my_courses_repository.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';

class DashboardFacade {
  const DashboardFacade({
    required DashboardRepository dashboardRepository,
    required MyCoursesRepository myCoursesRepository,
    required ProfileRepository profileRepository,
  }) : _dashboardRepository = dashboardRepository,
       _myCoursesRepository = myCoursesRepository,
       _profileRepository = profileRepository;

  final DashboardRepository _dashboardRepository;
  final MyCoursesRepository _myCoursesRepository;
  final ProfileRepository _profileRepository;

  Future<String> cachedProfileName() async {
    final cached = await _profileRepository.getCachedProfile();
    return cached?.fullName.trim() ?? '';
  }

  Future<MainDashboardData> load() async {
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);
    final startDate = endDate.subtract(const Duration(days: 6));

    final summary = await _dashboardRepository.fetchSummary(
      startDate: startDate,
      endDate: endDate,
      days: 7,
    );

    final fullName = await _loadProfileName();
    DashboardProgress? progress;
    DashboardTimeStats? timeStats;
    final coursePhotoById = <int, String>{};
    final summaryById = <int, DashboardCurrentCourse>{
      for (final course in summary.currentCourses) course.courseId: course,
    };
    List<DashboardCurrentCourse> currentCourses = [];
    List<MyCourseItem> myCourses = [];

    try {
      myCourses = await _myCoursesRepository.fetchMyCourses();
      for (final course in myCourses) {
        final photo = AppConfig.absoluteUrl(course.photo);
        if (photo != null && photo.isNotEmpty) {
          coursePhotoById[course.id] = photo;
        }
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to load my courses for dashboard fallback.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (myCourses.isNotEmpty) {
      final items = await Future.wait<DashboardCurrentCourse?>(
        myCourses.map((course) async {
          if (course.id <= 0) return null;

          var progressPercent =
              course.progressPercent ??
              summaryById[course.id]?.progressPercent ??
              0;
          try {
            final courseProgress = await _dashboardRepository.fetchProgress(
              courseId: course.id,
            );
            progressPercent = courseProgress.overallProgressPercent;
          } catch (error, stackTrace) {
            AppLogger.warning(
              'Failed to refresh dashboard progress for course ${course.id}.',
              error: error,
              stackTrace: stackTrace,
            );
          }

          final fallback = summaryById[course.id];
          final completed =
              course.completedActivities ?? fallback?.completedActivities ?? 0;
          final total =
              course.totalActivities ?? fallback?.totalActivities ?? 0;
          final name = (course.title ?? '').trim();

          return DashboardCurrentCourse(
            courseId: course.id,
            courseName: name.isNotEmpty ? name : 'Kurs #${course.id}',
            progressPercent: progressPercent,
            completedActivities: completed,
            totalActivities: total,
            isFinished: fallback?.isFinished ?? (progressPercent >= 100),
          );
        }),
      );
      currentCourses = items.whereType<DashboardCurrentCourse>().toList();
    }

    if (currentCourses.isEmpty) {
      currentCourses = summary.currentCourses;
    }

    for (final current in currentCourses) {
      if (coursePhotoById[current.courseId] != null) continue;
      try {
        final detail = await _myCoursesRepository.fetchCourseDetail(
          current.courseId,
        );
        final photo = AppConfig.absoluteUrl(detail.photo);
        if (photo != null && photo.isNotEmpty) {
          coursePhotoById[current.courseId] = photo;
        }
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Failed to load dashboard course detail for ${current.courseId}.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final firstCourseId = currentCourses.isNotEmpty
        ? currentCourses.first.courseId
        : null;

    if (firstCourseId != null && firstCourseId > 0) {
      final responses = await Future.wait<dynamic>([
        _dashboardRepository.fetchProgress(courseId: firstCourseId),
        _dashboardRepository.fetchTimeStats(
          startDate: startDate,
          endDate: endDate,
          courseId: firstCourseId,
        ),
      ]);
      progress = responses[0] as DashboardProgress;
      timeStats = responses[1] as DashboardTimeStats;
    }

    return MainDashboardData(
      fullName: fullName,
      summary: summary,
      currentCourses: currentCourses,
      progress: progress,
      timeStats: timeStats,
      coursePhotoById: coursePhotoById,
    );
  }

  Future<String> _loadProfileName() async {
    try {
      return (await _profileRepository.fetchProfile(
        forceRefresh: false,
      )).fullName.trim();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to load profile name, using cached profile name.',
        error: error,
        stackTrace: stackTrace,
      );
      return cachedProfileName();
    }
  }
}
