import 'package:uztelecom/core/routing/args/exam_route_args.dart';
import 'package:uztelecom/data/models/exam_models.dart';

ExamSessionData examSessionDataFromSession(ExamSession session) {
  return ExamSessionData(
    mode: session.mode,
    examAttemptId: session.examAttemptId,
    attemptNumber: session.attemptNumber,
    remainingTime: session.remainingTime,
    questions: session.questions
        .map(
          (question) => ExamQuestionData(
            id: question.id,
            text: question.text,
            answers: question.answers
                .map(
                  (answer) => ExamAnswerData(
                    id: answer.id,
                    text: answer.text,
                    isSelected: answer.isSelected,
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
  );
}
