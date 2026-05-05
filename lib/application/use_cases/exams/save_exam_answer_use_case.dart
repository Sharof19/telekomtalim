import 'package:uztelecom/data/repositories/exams_repository.dart';

class SaveExamAnswerUseCase {
  const SaveExamAnswerUseCase({required ExamsRepository examsRepository})
    : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<void> call({
    required int examId,
    required int questionId,
    required int answerId,
  }) {
    return _examsRepository.saveAnswer(
      examId: examId,
      questionId: questionId,
      answerId: answerId,
    );
  }
}
