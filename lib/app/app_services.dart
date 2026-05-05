import 'package:http/http.dart' as http;
import 'package:uztelecom/application/facades/dashboard_facade.dart';
import 'package:uztelecom/application/use_cases/auth/auth_use_cases.dart';
import 'package:uztelecom/application/use_cases/courses/course_use_cases.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/application/use_cases/media/media_use_cases.dart';
import 'package:uztelecom/application/use_cases/profile/profile_use_cases.dart';
import 'package:uztelecom/application/use_cases/schedule/schedule_use_cases.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/data/repositories/bbb_repository.dart';
import 'package:uztelecom/data/repositories/courses_repository.dart';
import 'package:uztelecom/data/repositories/dashboard_repository.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';
import 'package:uztelecom/data/repositories/my_courses_repository.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';
import 'package:uztelecom/data/repositories/schedule_repository.dart';

class AppServices {
  AppServices({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null {
    apiClient = ApiClient(
      client: _httpClient,
      authorizedRequest: ({required request, bool retryOnAuthError = true}) =>
          authRepository.authorizedRequest(
            request: request,
            retryOnAuthError: retryOnAuthError,
          ),
    );
    authRepository = AuthRepository(
      client: _httpClient,
      apiClient: apiClient,
      ownsClient: false,
    );
    dashboardRepository = DashboardRepository(
      client: _httpClient,
      authService: authRepository,
      apiClient: apiClient,
      ownsClient: false,
    );
    coursesRepository = CoursesRepository(
      client: _httpClient,
      authService: authRepository,
      apiClient: apiClient,
      ownsClient: false,
    );
    examsRepository = ExamsRepository(
      client: _httpClient,
      authService: authRepository,
      apiClient: apiClient,
      ownsClient: false,
    );
    myCoursesRepository = MyCoursesRepository(
      client: _httpClient,
      authService: authRepository,
      dashboardService: dashboardRepository,
      apiClient: apiClient,
      ownsClient: false,
      ownsDashboardService: false,
    );
    profileRepository = ProfileRepository(
      client: _httpClient,
      authService: authRepository,
      apiClient: apiClient,
      ownsClient: false,
    );
    scheduleRepository = ScheduleRepository(
      client: _httpClient,
      authService: authRepository,
      apiClient: apiClient,
      ownsClient: false,
    );
    bbbRepository = BbbRepository(
      client: _httpClient,
      authService: authRepository,
      apiClient: apiClient,
      ownsClient: false,
    );
    dashboardFacade = DashboardFacade(
      dashboardRepository: dashboardRepository,
      myCoursesRepository: myCoursesRepository,
      profileRepository: profileRepository,
    );
    checkAuthStatus = CheckAuthStatusUseCase(authRepository: authRepository);
    getValidAccessToken = GetValidAccessTokenUseCase(
      authRepository: authRepository,
    );
    requestLogin = RequestLoginUseCase(authRepository: authRepository);
    forgotPassword = ForgotPasswordUseCase(authRepository: authRepository);
    startHrmLogin = StartHrmLoginUseCase(authRepository: authRepository);
    completeHrmLogin = CompleteHrmLoginUseCase(
      authRepository: authRepository,
      profileRepository: profileRepository,
    );
    createPassword = CreatePasswordUseCase(
      authRepository: authRepository,
      profileRepository: profileRepository,
    );
    changePassword = ChangePasswordUseCase(
      authRepository: authRepository,
      profileRepository: profileRepository,
    );
    verifyOtp = VerifyOtpUseCase(
      authRepository: authRepository,
      profileRepository: profileRepository,
    );
    resendOtp = ResendOtpUseCase(authRepository: authRepository);
    logout = LogoutUseCase(authRepository: authRepository);
    buildAuthorizedVideoHeaders = BuildAuthorizedVideoHeadersUseCase(
      getValidAccessToken: getValidAccessToken,
    );
    resolveCourseResources = const ResolveCourseResourcesUseCase();
    loadCourses = LoadCoursesUseCase(coursesRepository: coursesRepository);
    loadMyCourses = LoadMyCoursesUseCase(
      myCoursesRepository: myCoursesRepository,
    );
    loadCourseDetail = LoadCourseDetailUseCase(
      coursesRepository: coursesRepository,
      myCoursesRepository: myCoursesRepository,
    );
    loadExams = LoadExamsUseCase(examsRepository: examsRepository);
    startExam = StartExamUseCase(examsRepository: examsRepository);
    loadExamAttempts = LoadExamAttemptsUseCase(
      examsRepository: examsRepository,
    );
    loadExamResult = LoadExamResultUseCase(examsRepository: examsRepository);
    saveExamAnswer = SaveExamAnswerUseCase(examsRepository: examsRepository);
    finishExam = FinishExamUseCase(examsRepository: examsRepository);
    loadProfile = LoadProfileUseCase(profileRepository: profileRepository);
    loadEditableProfile = LoadEditableProfileUseCase(
      profileRepository: profileRepository,
    );
    updateProfile = UpdateProfileUseCase(profileRepository: profileRepository);
    loadSchedule = LoadScheduleUseCase(scheduleRepository: scheduleRepository);
    joinPublicMeeting = JoinPublicMeetingUseCase(bbbRepository: bbbRepository);
  }

  final http.Client _httpClient;
  final bool _ownsHttpClient;
  var _disposed = false;

  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final DashboardRepository dashboardRepository;
  late final CoursesRepository coursesRepository;
  late final MyCoursesRepository myCoursesRepository;
  late final ExamsRepository examsRepository;
  late final ProfileRepository profileRepository;
  late final ScheduleRepository scheduleRepository;
  late final BbbRepository bbbRepository;
  late final DashboardFacade dashboardFacade;
  late final CheckAuthStatusUseCase checkAuthStatus;
  late final GetValidAccessTokenUseCase getValidAccessToken;
  late final RequestLoginUseCase requestLogin;
  late final ForgotPasswordUseCase forgotPassword;
  late final StartHrmLoginUseCase startHrmLogin;
  late final CompleteHrmLoginUseCase completeHrmLogin;
  late final CreatePasswordUseCase createPassword;
  late final ChangePasswordUseCase changePassword;
  late final VerifyOtpUseCase verifyOtp;
  late final ResendOtpUseCase resendOtp;
  late final LogoutUseCase logout;
  late final BuildAuthorizedVideoHeadersUseCase buildAuthorizedVideoHeaders;
  late final ResolveCourseResourcesUseCase resolveCourseResources;
  late final LoadCoursesUseCase loadCourses;
  late final LoadMyCoursesUseCase loadMyCourses;
  late final LoadCourseDetailUseCase loadCourseDetail;
  late final LoadExamsUseCase loadExams;
  late final StartExamUseCase startExam;
  late final LoadExamAttemptsUseCase loadExamAttempts;
  late final LoadExamResultUseCase loadExamResult;
  late final SaveExamAnswerUseCase saveExamAnswer;
  late final FinishExamUseCase finishExam;
  late final LoadProfileUseCase loadProfile;
  late final LoadEditableProfileUseCase loadEditableProfile;
  late final UpdateProfileUseCase updateProfile;
  late final LoadScheduleUseCase loadSchedule;
  late final JoinPublicMeetingUseCase joinPublicMeeting;

  http.Client get httpClient => _httpClient;

  void dispose() {
    if (_disposed) return;
    _disposed = true;

    myCoursesRepository.dispose();
    dashboardRepository.dispose();
    coursesRepository.dispose();
    examsRepository.dispose();
    profileRepository.dispose();
    scheduleRepository.dispose();
    bbbRepository.dispose();
    authRepository.dispose();

    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}
