import 'package:uztelecom/data/repositories/courses_repository.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';

class OtpRouteArgs {
  final String login;

  const OtpRouteArgs({required this.login});
}

class CourseInfoRouteArgs {
  final int courseId;
  final CourseItem? initialItem;
  final bool useMyCoursesDetailApi;

  const CourseInfoRouteArgs({
    required this.courseId,
    this.initialItem,
    this.useMyCoursesDetailApi = false,
  });
}

class ExamSessionRouteArgs {
  final int examId;
  final ExamSession session;
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

class ContentWebviewRouteArgs {
  final String url;
  final String title;
  final String? fallbackVideoUrl;

  const ContentWebviewRouteArgs({
    required this.url,
    required this.title,
    this.fallbackVideoUrl,
  });
}
