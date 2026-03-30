import 'package:uztelecom/core/config/app_config.dart';

abstract final class AppEndpoints {
  static Uri login() => AppConfig.apiV1Uri('login/');
  static Uri verifyCode() => AppConfig.apiV1Uri('verify-code/');
  static Uri resendCode() => AppConfig.apiV1Uri('resend-code/');
  static Uri refreshToken() => AppConfig.apiV1Uri('refresh-token/');
  static Uri logout() => AppConfig.apiV1Uri('logout/');

  static Uri profile() => AppConfig.apiV1Uri('profile/');
  static Uri changeProfile() => AppConfig.apiV1Uri('change-profile/');

  static Uri allowedResources() =>
      AppConfig.apiV1Uri('listener/allowed-resources/');
  static Uri allowedResourceDetail(int id) =>
      AppConfig.apiV1Uri('listener/allowed-resources/$id/detail/');

  static Uri myTrainingCourses() =>
      AppConfig.apiV1Uri('listener/my-training-courses/');
  static Uri myTrainingCourseDetail(int id) =>
      AppConfig.apiV1Uri('listener/my-training-courses/$id/detail/');

  static Uri dashboardProgress() => AppConfig.apiV1Uri('dashboard/progress/');
  static Uri dashboardSummary() => AppConfig.apiV1Uri('dashboard/summary/');
  static Uri dashboardTimeStats() =>
      AppConfig.apiV1Uri('dashboard/time-stats/');

  static Uri myExams() => AppConfig.apiV1Uri('my-exams/');
  static Uri startExam(int examId) =>
      AppConfig.apiV1Uri('my-exams/$examId/start/');
  static Uri saveExamAnswer() => AppConfig.apiV1Uri('exam/save-answer/');
  static Uri finishExam() => AppConfig.apiV1Uri('exam/finish/');
  static Uri examAttempts(int examId) =>
      AppConfig.apiV1Uri('exam/$examId/attempts/');
  static Uri examResult(int examId, int attemptNumber) =>
      AppConfig.apiV1Uri('exam/$examId/result/$attemptNumber/');

  static Uri listenerSchedule({
    required String startDate,
    required String endDate,
  }) => AppConfig.apiV1Uri(
    'listener/schedule/',
    queryParameters: {'start_date': startDate, 'end_date': endDate},
  );

  static Uri bbbJoin(String meetingId) =>
      AppConfig.apiV1Uri('bbb/join/$meetingId/public/');
}
