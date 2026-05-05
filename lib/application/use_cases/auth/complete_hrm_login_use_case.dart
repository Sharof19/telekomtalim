import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';
import 'package:uztelecom/data/models/profile_models.dart';

class CompleteHrmLoginUseCase {
  const CompleteHrmLoginUseCase({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository;

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  Future<ProfileInfo?> call({
    required String code,
    required String redirectUri,
    required String state,
  }) async {
    await _authRepository.exchangeOauthCallback(
      code: code,
      redirectUri: redirectUri,
      state: state,
    );
    try {
      return await _profileRepository.fetchProfile(forceRefresh: true);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Profile prefetch failed after HRM login.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
