import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';

class LoadExamResultUseCase {
  const LoadExamResultUseCase({required ExamsRepository examsRepository})
    : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<ExamResultDetail> call({
    required int examId,
    required int attemptNumber,
  }) {
    return _examsRepository.fetchResult(
      examId: examId,
      attemptNumber: attemptNumber,
    );
  }
}
