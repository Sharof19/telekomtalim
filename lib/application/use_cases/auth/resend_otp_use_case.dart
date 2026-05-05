import 'package:uztelecom/data/repositories/auth_repository.dart';

class ResendOtpUseCase {
  const ResendOtpUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> call({required String login}) {
    return _authRepository.resendCode(login: login);
  }
}
