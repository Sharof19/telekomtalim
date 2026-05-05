import 'package:uztelecom/data/repositories/exams_repository.dart';

class FinishExamUseCase {
  const FinishExamUseCase({required ExamsRepository examsRepository})
    : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<String?> call({required int examId}) {
    return _examsRepository.finishExam(examId: examId);
  }
}
