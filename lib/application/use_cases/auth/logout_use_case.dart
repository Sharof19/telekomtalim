import 'package:shared_preferences/shared_preferences.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> call() async {
    try {
      await _authRepository.logout();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Logout request failed; clearing local app state anyway.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
