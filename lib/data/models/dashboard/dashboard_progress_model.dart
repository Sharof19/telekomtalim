class DashboardProgress {
  final double overallProgressPercent;
  final int completedCourses;
  final int totalCourses;
  final int totalSpentSeconds;

  const DashboardProgress({
    required this.overallProgressPercent,
    required this.completedCourses,
    required this.totalCourses,
    required this.totalSpentSeconds,
  });

  factory DashboardProgress.fromJson(Map<String, dynamic> json) {
    return DashboardProgress(
      overallProgressPercent: (json['overall_progress_percent'] is num)
          ? (json['overall_progress_percent'] as num).toDouble()
          : 0,
      completedCourses: (json['completed_courses'] is num)
          ? (json['completed_courses'] as num).toInt()
          : 0,
      totalCourses: (json['total_courses'] is num)
          ? (json['total_courses'] as num).toInt()
          : 0,
      totalSpentSeconds: (json['total_spent_seconds'] is num)
          ? (json['total_spent_seconds'] as num).toInt()
          : 0,
    );
  }
}
