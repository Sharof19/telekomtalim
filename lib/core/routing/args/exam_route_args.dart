class ExamAnswerData {
  final int id;
  final String text;
  final bool isSelected;

  const ExamAnswerData({
    required this.id,
    required this.text,
    required this.isSelected,
  });
}

class ExamQuestionData {
  final int id;
  final String text;
  final List<ExamAnswerData> answers;

  const ExamQuestionData({
    required this.id,
    required this.text,
    required this.answers,
  });
}

class ExamSessionData {
  final String? mode;
  final int? examAttemptId;
  final int? attemptNumber;
  final int? remainingTime;
  final List<ExamQuestionData> questions;

  const ExamSessionData({
    this.mode,
    this.examAttemptId,
    this.attemptNumber,
    this.remainingTime,
    required this.questions,
  });
}

class ExamSessionRouteArgs {
  final int examId;
  final ExamSessionData session;
  final String title;

  const ExamSessionRouteArgs({
    required this.examId,
    required this.session,
    required this.title,
  });
}

class ExamAttemptsRouteArgs {
  final int examId;
  final String examTitle;

  const ExamAttemptsRouteArgs({required this.examId, required this.examTitle});
}

class ExamResultRouteArgs {
  final int examId;
  final String examTitle;
  final int attemptNumber;

  const ExamResultRouteArgs({
    required this.examId,
    required this.examTitle,
    required this.attemptNumber,
  });
}
