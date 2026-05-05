import 'package:uztelecom/data/models/exam/exam_model_utils.dart';

class ExamsResult {
  final List<ExamItem> items;
  final String? message;

  const ExamsResult({required this.items, this.message});
}

class ExamItem {
  final int examId;
  final String name;
  final DateTime? beginTime;
  final DateTime? endTime;
  final int? attempts;
  final bool canStart;
  final int? attemptsLeft;
  final String? message;

  const ExamItem({
    required this.examId,
    required this.name,
    required this.beginTime,
    required this.endTime,
    required this.attempts,
    required this.canStart,
    required this.attemptsLeft,
    required this.message,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      examId: (json['exam_id'] is num) ? (json['exam_id'] as num).toInt() : 0,
      name:
          json['exam_name']?.toString() ??
          json['title']?.toString() ??
          json['name']?.toString() ??
          'Imtihon',
      beginTime: parseExamDate(json['begin_time']?.toString()),
      endTime: parseExamDate(json['end_time']?.toString()),
      attempts: (json['attempts'] is num)
          ? (json['attempts'] as num).toInt()
          : null,
      canStart: json['can_start'] == true,
      attemptsLeft: (json['attempts_left'] is num)
          ? (json['attempts_left'] as num).toInt()
          : null,
      message: json['message']?.toString(),
    );
  }
}
