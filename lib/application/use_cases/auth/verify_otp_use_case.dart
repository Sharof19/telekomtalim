import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository;

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  Future<void> call({required String login, required String code}) async {
    await _authRepository.verifyCode(login: login, code: code);
    try {
      await _profileRepository.fetchProfile(forceRefresh: true);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Profile prefetch failed after OTP verification.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
