import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/domain/provider/provider.dart';
import 'package:uztelecom/domain/services/login_service.dart';

class CoursesService {
  CoursesService({http.Client? client, LoginService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? LoginService();

  final http.Client _client;
  final LoginService _authService;

  static const String _url =
      'https://eduapi.uztelecom.uz/api/v1/listener/allowed-resources/';

  Future<List<CourseItem>> fetchCourses() async {
    final items = <CourseItem>[];
    Uri? nextUrl = Uri.parse(_url);
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
      final data = body['data'] as List<dynamic>? ?? [];
      items.addAll(
        data.map((e) => CourseItem.fromJson(e as Map<String, dynamic>)),
      );

      final pagination = body['pagination'] as Map<String, dynamic>?;
      final next = pagination?['next']?.toString();
      nextUrl = (next != null && next.isNotEmpty) ? Uri.parse(next) : null;
      safety += 1;
    }

    return items;
  }

  Future<CourseItem> fetchCourseDetail(int id) async {
    final url =
        'https://eduapi.uztelecom.uz/api/v1/listener/allowed-resources/$id/detail/';
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ?? 'Kurs maʼlumotlarini olishda xatolik.',
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

  void dispose() {
    _client.close();
  }
}

class CourseItem {
  final int id;
  final String? title;
  final String? description;
  final String? status;
  final String? photo;
  final String? mainVideo;
  final String? file;
  final String? filePath;
  final String? launchUrl;
  final String? fullQuery;
  final String? duration;
  final int? hours;
  final int? days;
  final String? courseName;
  final String? language;
  final String? trainerName;
  final int? listenerCount;
  final String? trainingType;
  final String? specType;
  final String? comment;
  final String? sector;
  final String? sectorSpec;
  final String? audience;
  final String? execPlace;

  CourseItem({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.photo,
    this.mainVideo,
    this.file,
    this.filePath,
    this.launchUrl,
    this.fullQuery,
    this.duration,
    this.hours,
    this.days,
    this.courseName,
    this.language,
    this.trainerName,
    this.listenerCount,
    this.trainingType,
    this.specType,
    this.comment,
    this.sector,
    this.sectorSpec,
    this.audience,
    this.execPlace,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final source = _flattenEduResources(json);
    final language =
        source['language_display'] as Map<String, dynamic>? ?? {};
    final audiences = source['audiences'] as List<dynamic>? ?? [];
    final audience = audiences.isNotEmpty
        ? Map<String, dynamic>.from(audiences.first as Map)
        : <String, dynamic>{};
    return CourseItem(
      id: (source['id'] is num) ? (source['id'] as num).toInt() : 0,
      title: _pickLang(source, 'name'),
      description: _pickLang(source, 'description'),
      status: source['status_display']?.toString(),
      photo: source['photo']?.toString(),
      mainVideo: source['main_video']?.toString(),
      file: source['file']?.toString(),
      filePath: source['file_path']?.toString(),
      launchUrl: _pickLaunchUrl(json) ?? _pickLaunchUrl(source),
      fullQuery: _pickFullQuery(json) ?? _pickFullQuery(source),
      duration: source['duration_display']?.toString() ??
          source['duration']?.toString(),
      hours: (source['hours'] is num) ? (source['hours'] as num).toInt() : null,
      days: (source['days'] is num)
          ? (source['days'] as num).toInt()
          : (source['days_count'] is num)
              ? (source['days_count'] as num).toInt()
              : null,
      courseName: _pickLang(source, 'name'),
      language: _pickLang(language, 'name'),
      trainerName: _pickTrainerName(json) ?? _pickTrainerName(source),
      listenerCount: _pickInt(
        json['listener_count'],
      ) ??
          _pickInt(source['listener_count']),
      trainingType: null,
      specType: null,
      comment: null,
      sector: null,
      sectorSpec: null,
      audience: _pickLang(audience, 'name'),
      execPlace: null,
    );
  }

  static Map<String, dynamic> _flattenEduResources(Map<String, dynamic> json) {
    final source = Map<String, dynamic>.from(json);
    final rootId = source['id'];
    final nested = source['edu_resources'];
    if (nested is Map<String, dynamic>) {
      final nestedMap = Map<String, dynamic>.from(nested);
      source.addAll(nestedMap);
      // Keep outer course/enrollment id for detail endpoint calls.
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

  static String? _pickLang(Map<String, dynamic> map, String base) {
    final code = LocaleProvider.currentCode;
    final primary = '${base}_$code';
    final secondary = code == 'ru' ? '${base}_uz' : '${base}_ru';
    return map[primary]?.toString() ?? map[secondary]?.toString();
  }

  static int? _pickInt(Object? value) {
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
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
      'url',
      'href',
      'link',
    ];

    for (final key in directKeys) {
      final value = json[key]?.toString();
      if (_looksLikeLaunchUrl(value)) return value;
    }

    const nestedKeys = [
      'scorm',
      'xapi',
      'launch',
      'resource',
      'content',
      'player',
      'links',
    ];
    for (final key in nestedKeys) {
      final nested = json[key];
      if (nested is Map<String, dynamic>) {
        final nestedUrl = _pickLaunchUrl(nested);
        if (nestedUrl != null) return nestedUrl;
      }
    }

    return _findLaunchUrlDeep(json);
  }

  static String? _findLaunchUrlDeep(Object? value) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final found = _findLaunchUrlDeep(entry.value);
        if (found != null) return found;
      }
      return null;
    }
    if (value is List) {
      for (final item in value) {
        final found = _findLaunchUrlDeep(item);
        if (found != null) return found;
      }
      return null;
    }
    if (value is String && _looksLikeLaunchUrl(value)) {
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
    return _findStringByKeysDeep(json, keys.map((e) => e.toLowerCase()).toSet());
  }

  static String? _pickFullQuery(Map<String, dynamic> json) {
    final direct = _pickStringByKeysDeep(
      json,
      const [
        'full_query',
        'query',
        'launch_query',
        'scorm_query',
        'xapi_query',
      ],
    );
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
