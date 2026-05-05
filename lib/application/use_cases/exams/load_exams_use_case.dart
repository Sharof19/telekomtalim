import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';

class LoadExamsUseCase {
  const LoadExamsUseCase({required ExamsRepository examsRepository})
    : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<ExamsResult> call() {
    return _examsRepository.fetchMyExams();
  }
}
