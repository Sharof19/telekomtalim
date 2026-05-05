import 'package:uztelecom/data/models/profile_models.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  Future<void> call(EditableProfileInfo profile) {
    return _profileRepository.updateProfile(profile);
  }
}
