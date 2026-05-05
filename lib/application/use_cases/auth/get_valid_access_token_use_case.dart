import 'package:uztelecom/data/repositories/auth_repository.dart';

class GetValidAccessTokenUseCase {
  const GetValidAccessTokenUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<String?> call() {
    return _authRepository.getValidAccessToken();
  }
}
