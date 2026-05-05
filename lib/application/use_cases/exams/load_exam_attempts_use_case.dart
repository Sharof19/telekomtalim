import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';

class LoadExamAttemptsUseCase {
  const LoadExamAttemptsUseCase({required ExamsRepository examsRepository})
    : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<List<ExamAttemptItem>> call(int examId) {
    return _examsRepository.fetchAttempts(examId);
  }
}
