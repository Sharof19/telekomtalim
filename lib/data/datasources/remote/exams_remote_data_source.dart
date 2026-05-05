import 'dart:convert';

import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/exam_models.dart';

class ExamsRemoteDataSource {
  const ExamsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ExamsResult> fetchMyExams() async {
    final response = await _apiClient.get(
      AppEndpoints.myExams(),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Imtihonlarni olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
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
    final response = await _apiClient.post(
      AppEndpoints.startExam(examId),
      authorized: true,
      body: '',
    );
    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201},
      fallbackMessage: 'Imtihonni boshlashda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final status = body['status']?.toString();
    final message = body['message']?.toString();
    ApiClient.ensureBodyStatusOk(
      body,
      fallbackMessage: 'Imtihonni boshlashda xatolik.',
    );
    final data = ApiClient.dataMap(body);
    final session = ExamSession.fromJson(data);
    return ExamStartResult(status: status, message: message, session: session);
  }

  Future<void> saveAnswer({
    required int examId,
    required int questionId,
    required int answerId,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.saveExamAnswer(),
      authorized: true,
      headers: ApiClient.defaultAuthorizedJsonHeaders,
      body: jsonEncode({
        'exam_id': examId,
        'question_id': questionId,
        'answer_id': answerId,
      }),
    );
    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201},
      fallbackMessage: 'Javobni saqlashda xatolik yuz berdi.',
    );
  }

  Future<String?> finishExam({required int examId}) async {
    final response = await _apiClient.post(
      AppEndpoints.finishExam(),
      authorized: true,
      headers: ApiClient.defaultAuthorizedJsonHeaders,
      body: jsonEncode({'exam_id': examId}),
    );
    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201},
      fallbackMessage: 'Imtihonni tugatishda xatolik.',
    );

    try {
      final body = ApiClient.decodeObjectBody(response.body);
      return body['message']?.toString();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to parse finish exam message.',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Future<List<ExamAttemptItem>> fetchAttempts(int examId) async {
    final response = await _apiClient.get(
      AppEndpoints.examAttempts(examId),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Urinishlar tarixini olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
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
    final response = await _apiClient.get(
      AppEndpoints.examResult(examId, attemptNumber),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Natijani olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = ApiClient.dataMap(body);
    return ExamResultDetail.fromJson(data);
  }
}
