import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/domain/services/login_service.dart';

class ExamsService {
  ExamsService({http.Client? client, LoginService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? LoginService();

  final http.Client _client;
  final LoginService _authService;

  static const String _examsUrl =
      'https://eduapi.uztelecom.uz/api/v1/my-exams/';
  static const String _startSuffix = 'start/';
  static const String _saveAnswerUrl =
      'https://eduapi.uztelecom.uz/api/v1/exam/save-answer/';
  static const String _finishUrl =
      'https://eduapi.uztelecom.uz/api/v1/exam/finish/';
  static const String _examBaseUrl = 'https://eduapi.uztelecom.uz/api/v1/exam/';

  Future<ExamsResult> fetchMyExams() async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        Uri.parse(_examsUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ?? 'Imtihonlarni olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final message = body['message']?.toString();
    final data = body['data'];
    final itemsJson = data is List ? data : <dynamic>[];
    final items = itemsJson
        .whereType<Map<String, dynamic>>()
        .map(ExamItem.fromJson)
        .toList();
    return ExamsResult(items: items, message: message);
  }

  Future<ExamStartResult> startExam(int examId) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.post(
        Uri.parse('$_examsUrl$examId/$_startSuffix'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: '',
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _extractMessage(response.body) ?? 'Imtihonni boshlashda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status']?.toString();
    final message = body['message']?.toString();
    if (status == 'error') {
      throw Exception(message ?? 'Imtihonni boshlashda xatolik.');
    }
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final session = ExamSession.fromJson(data);
    return ExamStartResult(status: status, message: message, session: session);
  }

  Future<void> saveAnswer({
    required int examId,
    required int questionId,
    required int answerId,
  }) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.post(
        Uri.parse(_saveAnswerUrl),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'exam_id': examId,
          'question_id': questionId,
          'answer_id': answerId,
        }),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _extractMessage(response.body) ??
            'Javobni saqlashda xatolik yuz berdi.',
      );
    }
  }

  Future<String?> finishExam({required int examId}) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.post(
        Uri.parse(_finishUrl),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'exam_id': examId}),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _extractMessage(response.body) ?? 'Imtihonni tugatishda xatolik.',
      );
    }

    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body['message']?.toString();
      }
    } catch (_) {}
    return null;
  }

  Future<List<ExamAttemptItem>> fetchAttempts(int examId) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        Uri.parse('$_examBaseUrl$examId/attempts/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            'Urinishlar tarixini olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    final attemptsJson = data is List ? data : const <dynamic>[];
    return attemptsJson
        .whereType<Map<String, dynamic>>()
        .map(ExamAttemptItem.fromJson)
        .toList();
  }

  Future<ExamResultDetail> fetchResult({
    required int examId,
    required int attemptNumber,
  }) async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        Uri.parse('$_examBaseUrl$examId/result/$attemptNumber/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ?? 'Natijani olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ExamResultDetail.fromJson(data);
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

class ExamsResult {
  final List<ExamItem> items;
  final String? message;

  const ExamsResult({required this.items, this.message});
}

class ExamItem {
  final int examId;
  final String name;
  final DateTime? beginTime;
  final DateTime? endTime;
  final int? attempts;
  final bool canStart;
  final int? attemptsLeft;
  final String? message;

  const ExamItem({
    required this.examId,
    required this.name,
    required this.beginTime,
    required this.endTime,
    required this.attempts,
    required this.canStart,
    required this.attemptsLeft,
    required this.message,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      examId: (json['exam_id'] is num) ? (json['exam_id'] as num).toInt() : 0,
      name:
          json['exam_name']?.toString() ??
          json['title']?.toString() ??
          json['name']?.toString() ??
          'Imtihon',
      beginTime: _parseDate(json['begin_time']?.toString()),
      endTime: _parseDate(json['end_time']?.toString()),
      attempts: (json['attempts'] is num)
          ? (json['attempts'] as num).toInt()
          : null,
      canStart: json['can_start'] == true,
      attemptsLeft: (json['attempts_left'] is num)
          ? (json['attempts_left'] as num).toInt()
          : null,
      message: json['message']?.toString(),
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }
}

class ExamStartResult {
  final String? status;
  final String? message;
  final ExamSession? session;

  const ExamStartResult({this.status, this.message, this.session});
}

class ExamSession {
  final String? mode;
  final int? examAttemptId;
  final int? attemptNumber;
  final int? remainingTime;
  final List<ExamQuestion> questions;

  const ExamSession({
    this.mode,
    this.examAttemptId,
    this.attemptNumber,
    this.remainingTime,
    required this.questions,
  });

  factory ExamSession.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    return ExamSession(
      mode: json['mode']?.toString(),
      examAttemptId: (json['exam_attempt_id'] is num)
          ? (json['exam_attempt_id'] as num).toInt()
          : null,
      attemptNumber: (json['attempt_number'] is num)
          ? (json['attempt_number'] as num).toInt()
          : null,
      remainingTime: (json['remaining_time'] is num)
          ? (json['remaining_time'] as num).toInt()
          : null,
      questions: questionsJson
          .whereType<Map<String, dynamic>>()
          .map(ExamQuestion.fromJson)
          .toList(),
    );
  }
}

class ExamQuestion {
  final int id;
  final String text;
  final List<ExamAnswer> answers;

  const ExamQuestion({
    required this.id,
    required this.text,
    required this.answers,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? [];
    return ExamQuestion(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      answers: answersJson
          .whereType<Map<String, dynamic>>()
          .map(ExamAnswer.fromJson)
          .toList(),
    );
  }
}

class ExamAnswer {
  final int id;
  final String text;
  final bool isSelected;

  const ExamAnswer({
    required this.id,
    required this.text,
    required this.isSelected,
  });

  factory ExamAnswer.fromJson(Map<String, dynamic> json) {
    return ExamAnswer(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      isSelected: json['is_selected'] == true,
    );
  }
}

class ExamAttemptItem {
  final int attemptNumber;
  final DateTime? startTime;
  final DateTime? endTime;
  final int score;
  final String status;

  const ExamAttemptItem({
    required this.attemptNumber,
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.status,
  });

  factory ExamAttemptItem.fromJson(Map<String, dynamic> json) {
    return ExamAttemptItem(
      attemptNumber: (json['attempt_number'] is num)
          ? (json['attempt_number'] as num).toInt()
          : 0,
      startTime: _parseDate(json['start_time']?.toString()),
      endTime: _parseDate(json['end_time']?.toString()),
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
      status: json['status']?.toString() ?? '',
    );
  }
}

class ExamResultDetail {
  final int attemptNumber;
  final int score;
  final int maxScore;
  final List<ExamResultQuestion> questions;

  const ExamResultDetail({
    required this.attemptNumber,
    required this.score,
    required this.maxScore,
    required this.questions,
  });

  factory ExamResultDetail.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? const [];
    return ExamResultDetail(
      attemptNumber: (json['attempt_number'] is num)
          ? (json['attempt_number'] as num).toInt()
          : 0,
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
      maxScore: (json['max_score'] is num)
          ? (json['max_score'] as num).toInt()
          : 0,
      questions: questionsJson
          .whereType<Map<String, dynamic>>()
          .map(ExamResultQuestion.fromJson)
          .toList(),
    );
  }
}

class ExamResultQuestion {
  final int id;
  final String text;
  final List<ExamResultAnswer> answers;

  const ExamResultQuestion({
    required this.id,
    required this.text,
    required this.answers,
  });

  factory ExamResultQuestion.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? const [];
    return ExamResultQuestion(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      answers: answersJson
          .whereType<Map<String, dynamic>>()
          .map(ExamResultAnswer.fromJson)
          .toList(),
    );
  }
}

class ExamResultAnswer {
  final int id;
  final String text;
  final bool isSelected;
  final bool isTrue;

  const ExamResultAnswer({
    required this.id,
    required this.text,
    required this.isSelected,
    required this.isTrue,
  });

  factory ExamResultAnswer.fromJson(Map<String, dynamic> json) {
    return ExamResultAnswer(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      isSelected: json['is_selected'] == true,
      isTrue: json['is_true'] == true,
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return null;
  }
}
