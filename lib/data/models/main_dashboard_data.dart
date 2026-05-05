import 'package:uztelecom/data/models/dashboard_models.dart';

class MainDashboardData {
  final String fullName;
  final DashboardSummary summary;
  final List<DashboardCurrentCourse> currentCourses;
  final DashboardProgress? progress;
  final DashboardTimeStats? timeStats;
  final Map<int, String> coursePhotoById;

  const MainDashboardData({
    required this.fullName,
    required this.summary,
    required this.currentCourses,
    required this.progress,
    required this.timeStats,
    required this.coursePhotoById,
  });
}
