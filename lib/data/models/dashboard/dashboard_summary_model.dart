class DashboardCurrentCourse {
  final int courseId;
  final String courseName;
  final double progressPercent;
  final int completedActivities;
  final int totalActivities;
  final bool isFinished;

  const DashboardCurrentCourse({
    required this.courseId,
    required this.courseName,
    required this.progressPercent,
    required this.completedActivities,
    required this.totalActivities,
    required this.isFinished,
  });

  factory DashboardCurrentCourse.fromJson(Map<String, dynamic> json) {
    return DashboardCurrentCourse(
      courseId: (json['course_id'] is num)
          ? (json['course_id'] as num).toInt()
          : 0,
      courseName: json['course_name']?.toString() ?? '',
      progressPercent: (json['progress_percent'] is num)
          ? (json['progress_percent'] as num).toDouble()
          : 0,
      completedActivities: (json['completed_activities'] is num)
          ? (json['completed_activities'] as num).toInt()
          : 0,
      totalActivities: (json['total_activities'] is num)
          ? (json['total_activities'] as num).toInt()
          : 0,
      isFinished: json['is_finished'] == true,
    );
  }
}

class DashboardSummary {
  final int completedCoursesCount;
  final int activeCoursesCount;
  final List<DashboardCurrentCourse> currentCourses;
  final int totalSpentSeconds;
  final int weeklySpentSeconds;

  const DashboardSummary({
    required this.completedCoursesCount,
    required this.activeCoursesCount,
    required this.currentCourses,
    required this.totalSpentSeconds,
    required this.weeklySpentSeconds,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final courses = json['current_courses'] as List<dynamic>? ?? <dynamic>[];
    return DashboardSummary(
      completedCoursesCount: (json['completed_courses_count'] is num)
          ? (json['completed_courses_count'] as num).toInt()
          : 0,
      activeCoursesCount: (json['active_courses_count'] is num)
          ? (json['active_courses_count'] as num).toInt()
          : 0,
      currentCourses: courses
          .whereType<Map<String, dynamic>>()
          .map(DashboardCurrentCourse.fromJson)
          .toList(),
      totalSpentSeconds: (json['total_spent_seconds'] is num)
          ? (json['total_spent_seconds'] as num).toInt()
          : 0,
      weeklySpentSeconds: (json['weekly_spent_seconds'] is num)
          ? (json['weekly_spent_seconds'] as num).toInt()
          : 0,
    );
  }
}
