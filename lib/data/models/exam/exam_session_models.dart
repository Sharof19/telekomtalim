class ExamStartResult {
  final String? status;
  final String? message;
  final ExamSession? session;

  const ExamStartResult({this.status, this.message, this.session});
}

class ExamSession {
  final String? mode;
  final int? examAttemptId;
  final int? attemptNumber;
  final int? remainingTime;
  final List<ExamQuestion> questions;

  const ExamSession({
    this.mode,
    this.examAttemptId,
    this.attemptNumber,
    this.remainingTime,
    required this.questions,
  });

  factory ExamSession.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    return ExamSession(
      mode: json['mode']?.toString(),
      examAttemptId: (json['exam_attempt_id'] is num)
          ? (json['exam_attempt_id'] as num).toInt()
          : null,
      attemptNumber: (json['attempt_number'] is num)
          ? (json['attempt_number'] as num).toInt()
          : null,
      remainingTime: (json['remaining_time'] is num)
          ? (json['remaining_time'] as num).toInt()
          : null,
      questions: questionsJson
          .whereType<Map<String, dynamic>>()
          .map(ExamQuestion.fromJson)
          .toList(),
    );
  }
}

class ExamQuestion {
  final int id;
  final String text;
  final List<ExamAnswer> answers;

  const ExamQuestion({
    required this.id,
    required this.text,
    required this.answers,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? [];
    return ExamQuestion(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      answers: answersJson
          .whereType<Map<String, dynamic>>()
          .map(ExamAnswer.fromJson)
          .toList(),
    );
  }
}

class ExamAnswer {
  final int id;
  final String text;
  final bool isSelected;

  const ExamAnswer({
    required this.id,
    required this.text,
    required this.isSelected,
  });

  factory ExamAnswer.fromJson(Map<String, dynamic> json) {
    return ExamAnswer(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      isSelected: json['is_selected'] == true,
    );
  }
}
