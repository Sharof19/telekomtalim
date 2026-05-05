import 'package:uztelecom/data/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> call({required String phone}) {
    return _authRepository.forgotPassword(phone: phone);
  }
}
