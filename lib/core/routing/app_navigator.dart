import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/app_route_args.dart';
import 'package:uztelecom/core/routing/app_router.dart';
import 'package:uztelecom/core/routing/app_routes.dart';
import 'package:uztelecom/data/repositories/courses_repository.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';

export 'package:uztelecom/core/routing/app_route_args.dart';
export 'package:uztelecom/core/routing/app_router.dart';
export 'package:uztelecom/core/routing/app_routes.dart';

class AppNavigator {
  static const String initRoute = AppRouter.initialRoute;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return AppRouter.onGenerateRoute(settings);
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> replaceNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> replaceWithLogin<T, TO>(
    BuildContext context, {
    TO? result,
  }) {
    return replaceNamed<T, TO>(context, AppRoutes.login, result: result);
  }

  static Future<T?> replaceWithHome<T, TO>(BuildContext context, {TO? result}) {
    return replaceNamed<T, TO>(context, AppRoutes.home, result: result);
  }

  static Future<T?> replaceWithOtp<T, TO>(
    BuildContext context, {
    required String login,
    TO? result,
  }) {
    return replaceNamed<T, TO>(
      context,
      AppRoutes.otp,
      arguments: OtpRouteArgs(login: login),
      result: result,
    );
  }

  static Future<T?> resetToSplash<T>(BuildContext context) {
    return Navigator.of(
      context,
    ).pushNamedAndRemoveUntil<T>(AppRoutes.splash, (route) => false);
  }

  static Future<T?> pushNotifications<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.notifications);
  }

  static Future<T?> pushCoursesHub<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.coursesHub);
  }

  static Future<T?> pushCourses<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.courses);
  }

  static Future<T?> pushMyCourses<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.myCourses);
  }

  static Future<T?> pushWebinars<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.webinars);
  }

  static Future<T?> pushExams<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.exams);
  }

  static Future<T?> pushCertificates<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.certificates);
  }

  static Future<T?> pushSettings<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.settings);
  }

  static Future<T?> pushLanguage<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.language);
  }

  static Future<T?> pushSupport<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.support);
  }

  static Future<T?> pushProfileInfo<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.profileInfo);
  }

  static Future<T?> pushStatistics<T>(BuildContext context) {
    return pushNamed<T>(context, AppRoutes.statistics);
  }

  static Future<T?> pushCourseInfo<T>(
    BuildContext context, {
    required int courseId,
    CourseItem? initialItem,
    bool useMyCoursesDetailApi = false,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.courseInfo,
      arguments: CourseInfoRouteArgs(
        courseId: courseId,
        initialItem: initialItem,
        useMyCoursesDetailApi: useMyCoursesDetailApi,
      ),
    );
  }

  static Future<T?> pushExamSession<T>(
    BuildContext context, {
    required int examId,
    required ExamSession session,
    required String title,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.examSession,
      arguments: ExamSessionRouteArgs(
        examId: examId,
        session: session,
        title: title,
      ),
    );
  }

  static Future<T?> pushExamAttempts<T>(
    BuildContext context, {
    required int examId,
    required String examTitle,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.examAttempts,
      arguments: ExamAttemptsRouteArgs(examId: examId, examTitle: examTitle),
    );
  }

  static Future<T?> pushExamResult<T>(
    BuildContext context, {
    required int examId,
    required String examTitle,
    required int attemptNumber,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.examResult,
      arguments: ExamResultRouteArgs(
        examId: examId,
        examTitle: examTitle,
        attemptNumber: attemptNumber,
      ),
    );
  }

  static Future<T?> pushContentWebview<T>(
    BuildContext context, {
    required String url,
    required String title,
    String? fallbackVideoUrl,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.contentWebview,
      arguments: ContentWebviewRouteArgs(
        url: url,
        title: title,
        fallbackVideoUrl: fallbackVideoUrl,
      ),
    );
  }
}
