import 'package:uztelecom/data/models/exam/exam_model_utils.dart';

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
      startTime: parseExamDate(json['start_time']?.toString()),
      endTime: parseExamDate(json['end_time']?.toString()),
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
      status: json['status']?.toString() ?? '',
    );
  }
}
