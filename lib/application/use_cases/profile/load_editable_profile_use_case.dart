import 'package:uztelecom/data/models/profile_models.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';

class LoadEditableProfileUseCase {
  const LoadEditableProfileUseCase({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  Future<EditableProfileInfo> call() {
    return _profileRepository.fetchEditableProfile();
  }
}
