import 'package:http/http.dart' as http;
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/exams_remote_data_source.dart';
import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class ExamsRepository {
  factory ExamsRepository({
    http.Client? client,
    AuthRepository? authService,
    ApiClient? apiClient,
    bool? ownsClient,
  }) {
    final resolvedClient = client ?? http.Client();
    final resolvedAuthService =
        authService ?? AuthRepository(client: resolvedClient);
    return ExamsRepository._(
      client: resolvedClient,
      ownsClient: ownsClient ?? client == null,
      apiClient:
          apiClient ??
          ApiClient(
            client: resolvedClient,
            authorizedRequest: resolvedAuthService.authorizedRequest,
          ),
    );
  }

  ExamsRepository._({
    required http.Client client,
    required bool ownsClient,
    required ApiClient apiClient,
  }) : _client = client,
       _ownsClient = ownsClient,
       _remote = ExamsRemoteDataSource(apiClient: apiClient);

  final http.Client _client;
  final bool _ownsClient;
  final ExamsRemoteDataSource _remote;

  Future<ExamsResult> fetchMyExams() => _remote.fetchMyExams();

  Future<ExamStartResult> startExam(int examId) => _remote.startExam(examId);

  Future<void> saveAnswer({
    required int examId,
    required int questionId,
    required int answerId,
  }) => _remote.saveAnswer(
    examId: examId,
    questionId: questionId,
    answerId: answerId,
  );

  Future<String?> finishExam({required int examId}) =>
      _remote.finishExam(examId: examId);

  Future<List<ExamAttemptItem>> fetchAttempts(int examId) =>
      _remote.fetchAttempts(examId);

  Future<ExamResultDetail> fetchResult({
    required int examId,
    required int attemptNumber,
  }) => _remote.fetchResult(examId: examId, attemptNumber: attemptNumber);

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
