import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/auth_route_guard.dart';
import 'package:uztelecom/core/routing/app_route_args.dart';
import 'package:uztelecom/core/routing/app_routes.dart';
import 'package:uztelecom/ui/pages/auth/login_page.dart';
import 'package:uztelecom/ui/pages/auth/change_password_page.dart';
import 'package:uztelecom/ui/pages/auth/create_password_page.dart';
import 'package:uztelecom/ui/pages/auth/forgot_password_page.dart';
import 'package:uztelecom/ui/pages/auth/otp_page.dart';
import 'package:uztelecom/ui/pages/auth/splash_page.dart';
import 'package:uztelecom/ui/pages/courses/course_content_page.dart';
import 'package:uztelecom/ui/pages/courses/course_info_page.dart';
import 'package:uztelecom/ui/pages/courses/courses_hub_page.dart';
import 'package:uztelecom/ui/pages/courses/courses_page.dart';
import 'package:uztelecom/ui/pages/courses/my_courses_page.dart';
import 'package:uztelecom/ui/pages/exams/exam_attempts_page.dart';
import 'package:uztelecom/ui/pages/exams/exam_result_page.dart';
import 'package:uztelecom/ui/pages/exams/exam_session_page.dart';
import 'package:uztelecom/ui/pages/exams/exams_page.dart';
import 'package:uztelecom/ui/pages/home/home_page.dart';
import 'package:uztelecom/ui/pages/home/notifications_page.dart';
import 'package:uztelecom/ui/pages/home/statistics_page.dart';
import 'package:uztelecom/ui/pages/profile/certificates_page.dart';
import 'package:uztelecom/ui/pages/profile/language_page.dart';
import 'package:uztelecom/ui/pages/profile/my_applications_page.dart';
import 'package:uztelecom/ui/pages/profile/profile_info_page.dart';
import 'package:uztelecom/ui/pages/profile/profile_page.dart';
import 'package:uztelecom/ui/pages/profile/settings_page.dart';
import 'package:uztelecom/ui/pages/profile/support_page.dart';
import 'package:uztelecom/ui/pages/schedule/webinars_page.dart';

class AppRouteRegistry {
  static AppRouteEntry? find(String routeName) => _entries[routeName];

  static final Map<String, AppRouteEntry> _entries = <String, AppRouteEntry>{
    AppRoutes.splash: AppRouteEntry.pageBuilder(
      builder: () => const SplashPage(),
    ),
    AppRoutes.login: AppRouteEntry.pageBuilder(
      builder: () => const LoginPage(),
    ),
    AppRoutes.otp: AppRouteEntry.withArgs<OtpRouteArgs>(
      expectedArgs: 'OtpRouteArgs',
      builder: (args) =>
          OtpPage(login: args.login, resetPassword: args.resetPassword),
    ),
    AppRoutes.forgotPassword: AppRouteEntry.pageBuilder(
      builder: () => const ForgotPasswordPage(),
    ),
    AppRoutes.createPassword: AppRouteEntry.pageBuilder(
      builder: () => const CreatePasswordPage(),
      guarded: true,
    ),
    AppRoutes.changePassword: AppRouteEntry.pageBuilder(
      builder: () => const ChangePasswordPage(),
      guarded: true,
    ),
    AppRoutes.home: AppRouteEntry.pageBuilder(
      builder: () => const HomePage(),
      guarded: true,
    ),
    AppRoutes.notifications: AppRouteEntry.pageBuilder(
      builder: () => const NotificationsPage(),
      guarded: true,
    ),
    AppRoutes.coursesHub: AppRouteEntry.pageBuilder(
      builder: () => const CoursesHubPage(),
      guarded: true,
    ),
    AppRoutes.courses: AppRouteEntry.pageBuilder(
      builder: () => const CoursesPage(),
      guarded: true,
    ),
    AppRoutes.myCourses: AppRouteEntry.pageBuilder(
      builder: () => const MyCoursesPage(),
      guarded: true,
    ),
    AppRoutes.webinars: AppRouteEntry.pageBuilder(
      builder: () => const WebinarsPage(),
      guarded: true,
    ),
    AppRoutes.exams: AppRouteEntry.pageBuilder(
      builder: () => const ExamsPage(),
      guarded: true,
    ),
    AppRoutes.certificates: AppRouteEntry.pageBuilder(
      builder: () => const CertificatesPage(),
      guarded: true,
    ),
    AppRoutes.profile: AppRouteEntry.pageBuilder(
      builder: () => const ProfilePage(),
      guarded: true,
    ),
    AppRoutes.settings: AppRouteEntry.pageBuilder(
      builder: () => const SettingsPage(),
      guarded: true,
    ),
    AppRoutes.language: AppRouteEntry.pageBuilder(
      builder: () => const LanguagePage(),
      guarded: true,
    ),
    AppRoutes.support: AppRouteEntry.pageBuilder(
      builder: () => const SupportPage(),
      guarded: true,
    ),
    AppRoutes.profileInfo: AppRouteEntry.pageBuilder(
      builder: () => const ProfileInfoPage(),
      guarded: true,
    ),
    AppRoutes.statistics: AppRouteEntry.pageBuilder(
      builder: () => const StatisticsPage(),
      guarded: true,
    ),
    AppRoutes.courseInfo: AppRouteEntry.withArgs<CourseInfoRouteArgs>(
      expectedArgs: 'CourseInfoRouteArgs',
      guarded: true,
      builder: (args) => CourseInfoPage(
        courseId: args.courseId,
        initialItem: args.initialData,
        useMyCoursesDetailApi: args.useMyCoursesDetailApi,
      ),
    ),
    AppRoutes.examSession: AppRouteEntry.withArgs<ExamSessionRouteArgs>(
      expectedArgs: 'ExamSessionRouteArgs',
      guarded: true,
      builder: (args) => ExamSessionPage(
        examId: args.examId,
        session: args.session,
        title: args.title,
      ),
    ),
    AppRoutes.examAttempts: AppRouteEntry.withArgs<ExamAttemptsRouteArgs>(
      expectedArgs: 'ExamAttemptsRouteArgs',
      guarded: true,
      builder: (args) =>
          ExamAttemptsPage(examId: args.examId, examTitle: args.examTitle),
    ),
    AppRoutes.examResult: AppRouteEntry.withArgs<ExamResultRouteArgs>(
      expectedArgs: 'ExamResultRouteArgs',
      guarded: true,
      builder: (args) => ExamResultPage(
        examId: args.examId,
        examTitle: args.examTitle,
        attemptNumber: args.attemptNumber,
      ),
    ),
    AppRoutes.contentWebview: AppRouteEntry.withArgs<ContentWebviewRouteArgs>(
      expectedArgs: 'ContentWebviewRouteArgs',
      guarded: true,
      builder: (args) => ContentWebviewPage(
        url: args.url,
        title: args.title,
        fallbackVideoUrl: args.fallbackVideoUrl,
      ),
    ),
    AppRoutes.myApplications: AppRouteEntry.pageBuilder(
      builder: () => const MyApplicationsPage(),
      guarded: true,
    ),
  };
}

class AppRouteEntry {
  final bool guarded;
  final Widget Function(RouteSettings settings) _builder;

  const AppRouteEntry._({
    required this.guarded,
    required Widget Function(RouteSettings settings) builder,
  }) : _builder = builder;

  factory AppRouteEntry.pageBuilder({
    required Widget Function() builder,
    bool guarded = false,
  }) {
    return AppRouteEntry._(guarded: guarded, builder: (_) => builder());
  }

  static AppRouteEntry withArgs<T>({
    required String expectedArgs,
    required Widget Function(T args) builder,
    bool guarded = false,
  }) {
    return AppRouteEntry._(
      guarded: guarded,
      builder: (settings) {
        final args = settings.arguments;
        if (args is! T) {
          throw AppRouteBuildException(
            routeName: settings.name,
            expectedArgs: expectedArgs,
            actualArgs: args,
          );
        }
        return builder(args);
      },
    );
  }

  Route<dynamic> toRoute(RouteSettings settings) {
    final child = _builder(settings);
    final routedChild = guarded ? AuthRouteGuard(child: child) : child;
    return MaterialPageRoute(builder: (_) => routedChild, settings: settings);
  }
}

class AppRouteBuildException implements Exception {
  final String? routeName;
  final String expectedArgs;
  final Object? actualArgs;

  const AppRouteBuildException({
    required this.routeName,
    required this.expectedArgs,
    required this.actualArgs,
  });

  String get message {
    final name = routeName ?? '<null>';
    final actualType = actualArgs?.runtimeType.toString() ?? 'null';
    return 'Invalid arguments for $name. '
        'Expected: $expectedArgs, got: $actualType.';
  }

  @override
  String toString() => message;
}
