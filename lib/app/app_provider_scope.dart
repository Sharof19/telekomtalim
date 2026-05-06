import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/app/app_services.dart';
import 'package:uztelecom/application/facades/dashboard_facade.dart';
import 'package:uztelecom/application/use_cases/auth/auth_use_cases.dart';
import 'package:uztelecom/application/use_cases/courses/course_use_cases.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/application/use_cases/media/media_use_cases.dart';
import 'package:uztelecom/application/use_cases/notifications/notification_use_cases.dart';
import 'package:uztelecom/application/use_cases/profile/profile_use_cases.dart';
import 'package:uztelecom/application/use_cases/schedule/schedule_use_cases.dart';
import 'package:uztelecom/ui/providers/app/app_providers.dart';

class AppProviderScope extends StatefulWidget {
  final AppServices services;
  final ThemeModeProvider themeProvider;
  final LocaleProvider localeProvider;
  final Widget child;

  const AppProviderScope({
    super.key,
    required this.services,
    required this.themeProvider,
    required this.localeProvider,
    required this.child,
  });

  @override
  State<AppProviderScope> createState() => _AppProviderScopeState();
}

class _AppProviderScopeState extends State<AppProviderScope> {
  @override
  void dispose() {
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.services;
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: services),
        Provider<DashboardFacade>.value(value: services.dashboardFacade),
        Provider<CheckAuthStatusUseCase>.value(value: services.checkAuthStatus),
        Provider<GetValidAccessTokenUseCase>.value(
          value: services.getValidAccessToken,
        ),
        Provider<RequestLoginUseCase>.value(value: services.requestLogin),
        Provider<ForgotPasswordUseCase>.value(value: services.forgotPassword),
        Provider<StartHrmLoginUseCase>.value(value: services.startHrmLogin),
        Provider<CompleteHrmLoginUseCase>.value(
          value: services.completeHrmLogin,
        ),
        Provider<CreatePasswordUseCase>.value(value: services.createPassword),
        Provider<ChangePasswordUseCase>.value(value: services.changePassword),
        Provider<VerifyOtpUseCase>.value(value: services.verifyOtp),
        Provider<ResendOtpUseCase>.value(value: services.resendOtp),
        Provider<LogoutUseCase>.value(value: services.logout),
        Provider<BuildAuthorizedVideoHeadersUseCase>.value(
          value: services.buildAuthorizedVideoHeaders,
        ),
        Provider<ResolveCourseResourcesUseCase>.value(
          value: services.resolveCourseResources,
        ),
        Provider<LoadCoursesUseCase>.value(value: services.loadCourses),
        Provider<LoadMyCoursesUseCase>.value(value: services.loadMyCourses),
        Provider<LoadCourseDetailUseCase>.value(
          value: services.loadCourseDetail,
        ),
        Provider<LoadExamsUseCase>.value(value: services.loadExams),
        Provider<StartExamUseCase>.value(value: services.startExam),
        Provider<LoadExamAttemptsUseCase>.value(
          value: services.loadExamAttempts,
        ),
        Provider<LoadExamResultUseCase>.value(value: services.loadExamResult),
        Provider<SaveExamAnswerUseCase>.value(value: services.saveExamAnswer),
        Provider<FinishExamUseCase>.value(value: services.finishExam),
        Provider<LoadProfileUseCase>.value(value: services.loadProfile),
        Provider<LoadEditableProfileUseCase>.value(
          value: services.loadEditableProfile,
        ),
        Provider<UpdateProfileUseCase>.value(value: services.updateProfile),
        Provider<LoadScheduleUseCase>.value(value: services.loadSchedule),
        Provider<JoinPublicMeetingUseCase>.value(
          value: services.joinPublicMeeting,
        ),
        Provider<LoadNotificationsUseCase>.value(
          value: services.loadNotifications,
        ),
        ChangeNotifierProvider<ThemeModeProvider>.value(
          value: widget.themeProvider,
        ),
        ChangeNotifierProvider<LocaleProvider>.value(
          value: widget.localeProvider,
        ),
      ],
      child: widget.child,
    );
  }
}
