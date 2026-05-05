import 'package:flutter/material.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/data/models/exam_models.dart';

class ExamsProvider with ChangeNotifier {
  ExamsProvider({
    required LoadExamsUseCase loadExams,
    required StartExamUseCase startExam,
  }) : _loadExams = loadExams,
       _startExam = startExam;

  final LoadExamsUseCase _loadExams;
  final StartExamUseCase _startExam;

  bool _isLoading = true;
  Object? _error;
  ExamsResult? _result;
  final Set<int> _starting = <int>{};

  bool get isLoading => _isLoading;
  Object? get error => _error;
  ExamsResult? get result => _result;

  bool isStarting(int examId) => _starting.contains(examId);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _loadExams();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ExamStartResult> startExam(ExamItem item) async {
    if (_starting.contains(item.examId)) {
      return const ExamStartResult();
    }

    _starting.add(item.examId);
    notifyListeners();
    try {
      return await _startExam(item.examId);
    } finally {
      _starting.remove(item.examId);
      notifyListeners();
    }
  }
}
