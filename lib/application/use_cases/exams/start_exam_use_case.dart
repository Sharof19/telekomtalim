import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';

class StartExamUseCase {
  const StartExamUseCase({required ExamsRepository examsRepository})
    : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<ExamStartResult> call(int examId) {
    return _examsRepository.startExam(examId);
  }
}
