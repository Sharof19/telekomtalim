class ExamResultDetail {
  final int attemptNumber;
  final int score;
  final int maxScore;
  final List<ExamResultQuestion> questions;

  const ExamResultDetail({
    required this.attemptNumber,
    required this.score,
    required this.maxScore,
    required this.questions,
  });

  factory ExamResultDetail.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? const [];
    return ExamResultDetail(
      attemptNumber: (json['attempt_number'] is num)
          ? (json['attempt_number'] as num).toInt()
          : 0,
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
      maxScore: (json['max_score'] is num)
          ? (json['max_score'] as num).toInt()
          : 0,
      questions: questionsJson
          .whereType<Map<String, dynamic>>()
          .map(ExamResultQuestion.fromJson)
          .toList(),
    );
  }
}

class ExamResultQuestion {
  final int id;
  final String text;
  final List<ExamResultAnswer> answers;

  const ExamResultQuestion({
    required this.id,
    required this.text,
    required this.answers,
  });

  factory ExamResultQuestion.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? const [];
    return ExamResultQuestion(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      answers: answersJson
          .whereType<Map<String, dynamic>>()
          .map(ExamResultAnswer.fromJson)
          .toList(),
    );
  }
}

class ExamResultAnswer {
  final int id;
  final String text;
  final bool isSelected;
  final bool isTrue;

  const ExamResultAnswer({
    required this.id,
    required this.text,
    required this.isSelected,
    required this.isTrue,
  });

  factory ExamResultAnswer.fromJson(Map<String, dynamic> json) {
    return ExamResultAnswer(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      text: json['text']?.toString() ?? '',
      isSelected: json['is_selected'] == true,
      isTrue: json['is_true'] == true,
    );
  }
}
