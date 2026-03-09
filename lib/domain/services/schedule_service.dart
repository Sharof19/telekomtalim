import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/domain/services/login_service.dart';

class ScheduleService {
  ScheduleService({http.Client? client, LoginService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? LoginService();

  final http.Client _client;
  final LoginService _authService;

  static const String _baseUrl =
      'https://eduapi.uztelecom.uz/api/v1/listener/schedule/';

  Future<ScheduleData> fetchSchedule({
    required String startDate,
    required String endDate,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
    });

    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ?? 'Jadvalni olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Jadval topilmadi.');
    }

    return ScheduleData.fromJson(data);
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

class ScheduleData {
  final SchedulePeriod period;
  final List<ScheduleColumn> columns;
  final List<ScheduleRow> rows;

  const ScheduleData({
    required this.period,
    required this.columns,
    required this.rows,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    final periodJson = json['period'] as Map<String, dynamic>? ?? {};
    final columnsJson = json['columns'] as List<dynamic>? ?? [];
    final rowsJson = json['rows'] as List<dynamic>? ?? [];
    return ScheduleData(
      period: SchedulePeriod.fromJson(periodJson),
      columns: columnsJson
          .map((e) => ScheduleColumn.fromJson(e as Map<String, dynamic>))
          .toList(),
      rows: rowsJson
          .map((e) => ScheduleRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SchedulePeriod {
  final String startDate;
  final String endDate;

  const SchedulePeriod({required this.startDate, required this.endDate});

  factory SchedulePeriod.fromJson(Map<String, dynamic> json) {
    return SchedulePeriod(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }
}

class ScheduleColumn {
  final String date;
  final String label;
  final int day;
  final bool isToday;

  const ScheduleColumn({
    required this.date,
    required this.label,
    required this.day,
    required this.isToday,
  });

  factory ScheduleColumn.fromJson(Map<String, dynamic> json) {
    return ScheduleColumn(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      day: (json['day'] is num) ? (json['day'] as num).toInt() : 0,
      isToday: json['is_today'] == true,
    );
  }
}

class ScheduleRow {
  final int pairId;
  final String label;
  final String time;
  final List<ScheduleCell> cells;

  const ScheduleRow({
    required this.pairId,
    required this.label,
    required this.time,
    required this.cells,
  });

  factory ScheduleRow.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List<dynamic>? ?? [];
    return ScheduleRow(
      pairId: (json['pair_id'] is num) ? (json['pair_id'] as num).toInt() : 0,
      label: json['label']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      cells: cellsJson
          .map((e) => ScheduleCell.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScheduleCell {
  final bool hasLesson;
  final LessonInfo? lesson;

  const ScheduleCell({required this.hasLesson, this.lesson});

  factory ScheduleCell.fromJson(Map<String, dynamic> json) {
    return ScheduleCell(
      hasLesson: json['has_lesson'] == true,
      lesson: json['lesson'] is Map<String, dynamic>
          ? LessonInfo.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LessonInfo {
  final int id;
  final String? group;
  final String? theme;
  final int? listeners;
  final String? educationType;
  final bool isOnline;
  final BbbObject bbbObject;

  const LessonInfo({
    required this.id,
    this.group,
    this.theme,
    this.listeners,
    this.educationType,
    required this.isOnline,
    required this.bbbObject,
  });

  factory LessonInfo.fromJson(Map<String, dynamic> json) {
    return LessonInfo(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      group: json['group']?.toString(),
      theme: json['theme']?.toString(),
      listeners: (json['listeners'] is num)
          ? (json['listeners'] as num).toInt()
          : null,
      educationType: json['education_type']?.toString(),
      isOnline: json['is_online'] == true,
      bbbObject: BbbObject.fromJson(
        json['bbb_object'] is Map<String, dynamic>
            ? json['bbb_object'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}

class BbbObject {
  final bool hasBbbCreate;
  final String? meetingId;

  const BbbObject({required this.hasBbbCreate, this.meetingId});

  factory BbbObject.fromJson(Map<String, dynamic> json) {
    return BbbObject(
      hasBbbCreate: json['has_bbb_create'] == true,
      meetingId: json['meeting_id']?.toString(),
    );
  }
}
