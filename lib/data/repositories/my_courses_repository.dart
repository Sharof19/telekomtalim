import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/repositories/courses_repository.dart';
import 'package:uztelecom/data/repositories/dashboard_repository.dart';
import 'package:uztelecom/domain/provider/provider.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class MyCoursesRepository {
  MyCoursesRepository({http.Client? client, AuthRepository? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthRepository(),
      _dashboardService = DashboardRepository();

  final http.Client _client;
  final AuthRepository _authService;
  final DashboardRepository _dashboardService;

  Future<List<MyCourseItem>> fetchMyCourses() async {
    final items = <MyCourseItem>[];
    Uri? nextUrl = AppEndpoints.myTrainingCourses();
    var safety = 0;

    while (nextUrl != null && safety < 10) {
      final response = await _authService.authorizedRequest(
        request: (token) => _client.get(
          nextUrl!,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          _extractMessage(response.body) ?? 'Kurslarni olishda xatolik.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status']?.toString();
      if (status == 'error') {
        throw Exception(
          body['message']?.toString() ?? 'Kurslarni olishda xatolik.',
        );
      }
      final data = body['data'] as List<dynamic>? ?? [];
      items.addAll(
        data.whereType<Map<String, dynamic>>().map(MyCourseItem.fromJson),
      );

      final pagination = body['pagination'] as Map<String, dynamic>?;
      final next = pagination?['next']?.toString();
      nextUrl = (next != null && next.isNotEmpty) ? Uri.parse(next) : null;
      safety += 1;
    }

    return _enrichProgress(items);
  }

  Future<CourseItem> fetchCourseDetail(int id) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        AppEndpoints.myTrainingCourseDetail(id),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            "Kurs ma'lumotlarini olishda xatolik.",
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return CourseItem.fromJson(data);
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
    } catch (_) {
      return items;
    }
  }

  String _normalizeTitle(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  void dispose() {
    _client.close();
    _dashboardService.dispose();
  }
}

class MyCourseItem {
  final int id;
  final String? title;
  final String? description;
  final String? status;
  final String? photo;
  final String? mainVideo;
  final String? filePath;
  final String? launchUrl;
  final String? fullQuery;
  final String? duration;
  final String? language;
  final String? audience;
  final String? trainerName;
  final int? listenerCount;
  final double? progressPercent;
  final int? completedActivities;
  final int? totalActivities;

  const MyCourseItem({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.photo,
    this.mainVideo,
    this.filePath,
    this.launchUrl,
    this.fullQuery,
    this.duration,
    this.language,
    this.audience,
    this.trainerName,
    this.listenerCount,
    this.progressPercent,
    this.completedActivities,
    this.totalActivities,
  });

  factory MyCourseItem.fromJson(Map<String, dynamic> json) {
    final source = _flattenEduResources(json);
    final language = source['language_display'] as Map<String, dynamic>? ?? {};
    final audiences = source['audiences'] as List<dynamic>? ?? [];
    final audience = audiences.isNotEmpty
        ? Map<String, dynamic>.from(audiences.first as Map)
        : <String, dynamic>{};
    return MyCourseItem(
      id: (source['id'] is num) ? (source['id'] as num).toInt() : 0,
      title: _pickLang(source, 'name'),
      description: _pickLang(source, 'description'),
      status: source['status_display']?.toString(),
      photo: source['photo']?.toString(),
      mainVideo: source['main_video']?.toString(),
      filePath: source['file_path']?.toString(),
      launchUrl: _pickLaunchUrl(json) ?? _pickLaunchUrl(source),
      fullQuery: _pickFullQuery(json) ?? _pickFullQuery(source),
      duration:
          source['duration_display']?.toString() ??
          source['duration']?.toString(),
      language: _pickLang(language, 'name'),
      audience: _pickLang(audience, 'name'),
      trainerName: _pickTrainerName(json) ?? _pickTrainerName(source),
      listenerCount:
          _pickInt(json['listener_count']) ??
          _pickInt(source['listener_count']),
      progressPercent:
          _pickDouble(json['progress_percent']) ??
          _pickDouble(source['progress_percent']) ??
          _pickDouble(json['progress']),
      completedActivities:
          _pickInt(json['completed_activities']) ??
          _pickInt(source['completed_activities']) ??
          _pickInt(json['completed_modules']) ??
          _pickInt(json['completed_lessons']) ??
          _pickInt(source['completed_modules']) ??
          _pickInt(source['completed_lessons']),
      totalActivities:
          _pickInt(json['total_activities']) ??
          _pickInt(source['total_activities']) ??
          _pickInt(json['total_modules']) ??
          _pickInt(json['total_lessons']) ??
          _pickInt(source['total_modules']) ??
          _pickInt(source['total_lessons']),
    );
  }

  MyCourseItem copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? photo,
    String? mainVideo,
    String? filePath,
    String? launchUrl,
    String? fullQuery,
    String? duration,
    String? language,
    String? audience,
    String? trainerName,
    int? listenerCount,
    double? progressPercent,
    int? completedActivities,
    int? totalActivities,
  }) {
    return MyCourseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      mainVideo: mainVideo ?? this.mainVideo,
      filePath: filePath ?? this.filePath,
      launchUrl: launchUrl ?? this.launchUrl,
      fullQuery: fullQuery ?? this.fullQuery,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      audience: audience ?? this.audience,
      trainerName: trainerName ?? this.trainerName,
      listenerCount: listenerCount ?? this.listenerCount,
      progressPercent: progressPercent ?? this.progressPercent,
      completedActivities: completedActivities ?? this.completedActivities,
      totalActivities: totalActivities ?? this.totalActivities,
    );
  }

  static Map<String, dynamic> _flattenEduResources(Map<String, dynamic> json) {
    final source = Map<String, dynamic>.from(json);
    final rootId = source['id'];
    final nested = source['edu_resources'];
    if (nested is Map<String, dynamic>) {
      final nestedMap = Map<String, dynamic>.from(nested);
      source.addAll(nestedMap);
      if (rootId != null) {
        source['id'] = rootId;
        source['course_item_id'] = rootId;
      }
      if (nestedMap['id'] != null) {
        source['edu_resource_id'] = nestedMap['id'];
      }
    }
    return source;
  }

  static String? _pickLang(Map<String, dynamic>? map, String base) {
    if (map == null) return null;
    final code = LocaleProvider.currentCode;
    final primary = '${base}_$code';
    final secondary = code == 'ru' ? '${base}_uz' : '${base}_ru';
    return map[primary]?.toString() ??
        map[secondary]?.toString() ??
        map[base]?.toString();
  }

  static int? _pickInt(Object? value) {
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? _pickDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static String? _pickTrainerName(Map<String, dynamic> map) {
    final trainers = map['trainers'];
    if (trainers is List && trainers.isNotEmpty) {
      final first = trainers.first;
      if (first is Map) {
        final trainer = Map<String, dynamic>.from(first);
        final direct = trainer['full_name']?.toString();
        if (direct != null && direct.isNotEmpty) return direct;
        final employee = trainer['employee_display'];
        if (employee is Map) {
          final employeeMap = Map<String, dynamic>.from(employee);
          final fullName = employeeMap['full_name']?.toString();
          if (fullName != null && fullName.isNotEmpty) return fullName;
        }
      }
    }
    return null;
  }

  static String? _pickLaunchUrl(Map<String, dynamic> json) {
    const directKeys = [
      'launch_url',
      'scorm_launch_url',
      'scorm_url',
      'content_url',
      'resource_url',
      'viewer_url',
      'open_url',
      'index_api_url',
      'index_url',
    ];
    for (final key in directKeys) {
      final value = json[key]?.toString();
      if (_looksLikeLaunchUrl(value)) return value;
    }
    return _findLaunchUrlDeep(json);
  }

  static String? _findLaunchUrlDeep(Object? value) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final found = _findLaunchUrlDeep(entry.value);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final item in value) {
        final found = _findLaunchUrlDeep(item);
        if (found != null) return found;
      }
    } else if (value is String && _looksLikeLaunchUrl(value)) {
      return value;
    }
    return null;
  }

  static bool _looksLikeLaunchUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (!(lower.startsWith('http://') || lower.startsWith('https://'))) {
      return false;
    }
    return lower.contains('/scormdriver/indexapi.html') ||
        lower.contains('lrs.uztelecom.uz') ||
        lower.contains('auth=bearer%20') ||
        (lower.contains('registration=') && lower.contains('actor='));
  }

  static String? _pickStringByKeysDeep(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return _findStringByKeysDeep(
      json,
      keys.map((e) => e.toLowerCase()).toSet(),
    );
  }

  static String? _pickFullQuery(Map<String, dynamic> json) {
    final direct = _pickStringByKeysDeep(json, const [
      'full_query',
      'query',
      'launch_query',
      'scorm_query',
      'xapi_query',
    ]);
    if (_looksLikeFullQuery(direct)) return direct;
    return _findFullQueryDeep(json);
  }

  static String? _findStringByKeysDeep(Object? value, Set<String> wantedKeys) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        if (wantedKeys.contains(entry.key.toLowerCase())) {
          final text = entry.value?.toString();
          if (text != null && text.isNotEmpty) return text;
        }
        final nested = _findStringByKeysDeep(entry.value, wantedKeys);
        if (nested != null) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _findStringByKeysDeep(item, wantedKeys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static String? _findFullQueryDeep(Object? value) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final direct = entry.value?.toString();
        if (_looksLikeFullQuery(direct)) return direct;
        final nested = _findFullQueryDeep(entry.value);
        if (nested != null) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _findFullQueryDeep(item);
        if (nested != null) return nested;
      }
    } else if (value is String && _looksLikeFullQuery(value)) {
      return value;
    }
    return null;
  }

  static bool _looksLikeFullQuery(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return false;
    }
    return lower.contains('endpoint=') &&
        lower.contains('registration=') &&
        lower.contains('actor=');
  }
}
