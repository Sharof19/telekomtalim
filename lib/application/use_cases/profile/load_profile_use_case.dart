import 'package:uztelecom/data/models/profile_models.dart';
import 'package:uztelecom/data/repositories/profile_repository.dart';

class LoadProfileUseCase {
  const LoadProfileUseCase({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  Future<ProfileInfo> call({bool forceRefresh = false}) {
    return _profileRepository.fetchProfile(forceRefresh: forceRefresh);
  }
}
