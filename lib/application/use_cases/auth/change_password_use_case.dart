import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository;

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  Future<void> call({
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _authRepository.changePassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    await _profileRepository.fetchProfile(forceRefresh: true);
  }
}
