import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/app_route_args.dart';
import 'package:uztelecom/core/routing/app_routes.dart';
import 'package:uztelecom/ui/pages/auth_pages/login_screen.dart';
import 'package:uztelecom/ui/pages/auth_pages/otp_page.dart';
import 'package:uztelecom/ui/pages/auth_pages/splash_screen.dart';
import 'package:uztelecom/ui/pages/certificates_page.dart';
import 'package:uztelecom/ui/pages/content_webview_page.dart';
import 'package:uztelecom/ui/pages/courses_hub_page.dart';
import 'package:uztelecom/ui/pages/darslar_page.dart';
import 'package:uztelecom/ui/pages/exam_attempts_page.dart';
import 'package:uztelecom/ui/pages/exam_session_page.dart';
import 'package:uztelecom/ui/pages/exams_page.dart';
import 'package:uztelecom/ui/pages/home_page.dart';
import 'package:uztelecom/ui/pages/my_courses_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/pages/profil.dart';
import 'package:uztelecom/ui/pages/settings_pages/language_page.dart';
import 'package:uztelecom/ui/pages/settings_pages/profile_info_page.dart';
import 'package:uztelecom/ui/pages/settings_pages/settings_page.dart';
import 'package:uztelecom/ui/pages/settings_pages/support_page.dart';
import 'package:uztelecom/ui/pages/statistics_page.dart';
import 'package:uztelecom/ui/pages/table_page.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class AppRouter {
  static const String initialRoute = AppRoutes.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _guardedPage(settings, const SplashScreen());
      case AppRoutes.login:
        return _guardedPage(settings, const LoginPage());
      case AppRoutes.otp:
        final args = settings.arguments;
        final login = switch (args) {
          OtpRouteArgs(:final login) => login,
          String value => value,
          _ => '',
        };
        return _guardedPage(settings, OtpPage(login: login));
      case AppRoutes.home:
        return _guardedPage(settings, const HomePage());
      case AppRoutes.notifications:
        return _guardedPage(settings, const NotificationsPage());
      case AppRoutes.coursesHub:
        return _guardedPage(settings, const CoursesHubPage());
      case AppRoutes.courses:
        return _guardedPage(settings, const CoursesPage());
      case AppRoutes.myCourses:
        return _guardedPage(settings, const MyCoursesPage());
      case AppRoutes.webinars:
        return _guardedPage(settings, const TablePage());
      case AppRoutes.exams:
        return _guardedPage(settings, const ExamsPage());
      case AppRoutes.certificates:
        return _guardedPage(settings, const CertificatesPage());
      case AppRoutes.profile:
        return _guardedPage(settings, const ProfilePage());
      case AppRoutes.settings:
        return _guardedPage(settings, const SettingsPage());
      case AppRoutes.language:
        return _guardedPage(settings, const LanguagePage());
      case AppRoutes.support:
        return _page(settings, const SupportPage());
      case AppRoutes.profileInfo:
        return _guardedPage(settings, const ProfileInfoPage());
      case AppRoutes.statistics:
        return _guardedPage(settings, const StatisticsPage());
      case AppRoutes.courseInfo:
        final args = settings.arguments;
        if (args is! CourseInfoRouteArgs) {
          return _unknownRoute(settings);
        }
        return _guardedPage(
          settings,
          CourseInfoPage(
            courseId: args.courseId,
            initialItem: args.initialItem,
            useMyCoursesDetailApi: args.useMyCoursesDetailApi,
          ),
        );
      case AppRoutes.examSession:
        final args = settings.arguments;
        if (args is! ExamSessionRouteArgs) {
          return _unknownRoute(settings);
        }
        return _page(
          settings,
          ExamSessionPage(
            examId: args.examId,
            session: args.session,
            title: args.title,
          ),
        );
      case AppRoutes.examAttempts:
        final args = settings.arguments;
        if (args is! ExamAttemptsRouteArgs) {
          return _unknownRoute(settings);
        }
        return _page(
          settings,
          ExamAttemptsPage(examId: args.examId, examTitle: args.examTitle),
        );
      case AppRoutes.examResult:
        final args = settings.arguments;
        if (args is! ExamResultRouteArgs) {
          return _unknownRoute(settings);
        }
        return _page(
          settings,
          ExamResultPage(
            examId: args.examId,
            examTitle: args.examTitle,
            attemptNumber: args.attemptNumber,
          ),
        );
      case AppRoutes.contentWebview:
        final args = settings.arguments;
        if (args is! ContentWebviewRouteArgs) {
          return _unknownRoute(settings);
        }
        return _page(
          settings,
          ContentWebviewPage(
            url: args.url,
            title: args.title,
            fallbackVideoUrl: args.fallbackVideoUrl,
          ),
        );
      case AppRoutes.myApplications:
        return _guardedPage(settings, const MyApplicationsPage());
      default:
        return _unknownRoute(settings);
    }
  }

  static MaterialPageRoute<dynamic> _guardedPage(
    RouteSettings settings,
    Widget child,
  ) {
    return _page(settings, ConnectivityGate(child: child));
  }

  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }

  static MaterialPageRoute<dynamic> _unknownRoute(RouteSettings settings) {
    return _guardedPage(settings, const SplashScreen());
  }
}
