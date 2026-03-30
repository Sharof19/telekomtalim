import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class DashboardRepository {
  DashboardRepository({http.Client? client, AuthRepository? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthRepository();

  final http.Client _client;
  final AuthRepository _authService;

  Future<DashboardProgress> fetchProgress({required int courseId}) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        AppEndpoints.dashboardProgress().replace(
          queryParameters: {'course_id': '$courseId'},
        ),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            'Progress ma\'lumotini olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DashboardProgress.fromJson(data);
  }

  Future<DashboardSummary> fetchSummary({
    required DateTime startDate,
    required DateTime endDate,
    int days = 7,
  }) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        AppEndpoints.dashboardSummary().replace(
          queryParameters: {
            'start_date': _fmtDate(startDate),
            'end_date': _fmtDate(endDate),
            'days': '$days',
          },
        ),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            'Dashboard statistikani olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DashboardSummary.fromJson(data);
  }

  Future<DashboardTimeStats> fetchTimeStats({
    required DateTime startDate,
    required DateTime endDate,
    required int courseId,
  }) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        AppEndpoints.dashboardTimeStats().replace(
          queryParameters: {
            'start_date': _fmtDate(startDate),
            'end_date': _fmtDate(endDate),
            'course_id': '$courseId',
          },
        ),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            'Vaqt statistikasini olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DashboardTimeStats.fromJson(data);
  }

  String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        return json['message']?.toString();
      }
    } catch (_) {}
    return null;
  }

  String _fmtDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void dispose() {
    _client.close();
  }
}

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

class DashboardTimeStats {
  final List<DashboardDayStat> days;
  final int periodTotalSpentSeconds;
  final int totalSpentSeconds;

  const DashboardTimeStats({
    required this.days,
    required this.periodTotalSpentSeconds,
    required this.totalSpentSeconds,
  });

  factory DashboardTimeStats.fromJson(Map<String, dynamic> json) {
    final dayItems = json['days'] as List<dynamic>? ?? <dynamic>[];
    return DashboardTimeStats(
      days: dayItems
          .whereType<Map<String, dynamic>>()
          .map(DashboardDayStat.fromJson)
          .toList(),
      periodTotalSpentSeconds: (json['period_total_spent_seconds'] is num)
          ? (json['period_total_spent_seconds'] as num).toInt()
          : 0,
      totalSpentSeconds: (json['total_spent_seconds'] is num)
          ? (json['total_spent_seconds'] as num).toInt()
          : 0,
    );
  }
}

class DashboardDayStat {
  final String date;
  final int total;

  const DashboardDayStat({required this.date, required this.total});

  factory DashboardDayStat.fromJson(Map<String, dynamic> json) {
    return DashboardDayStat(
      date: json['date']?.toString() ?? '',
      total: (json['total'] is num) ? (json['total'] as num).toInt() : 0,
    );
  }
}
