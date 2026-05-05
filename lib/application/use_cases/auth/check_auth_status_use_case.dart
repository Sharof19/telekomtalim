import 'package:uztelecom/data/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<bool> call() async {
    final token = await _authRepository.getValidAccessToken();
    return token != null && token.isNotEmpty;
  }
}
