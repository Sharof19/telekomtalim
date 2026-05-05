import 'package:uztelecom/data/repositories/auth_repository.dart';

class RequestLoginUseCase {
  const RequestLoginUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> call({required String login, required String password}) {
    return _authRepository.requestLogin(login: login, password: password);
  }
}
