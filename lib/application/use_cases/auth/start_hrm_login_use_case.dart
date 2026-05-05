import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';

class HrmLoginRequest {
  const HrmLoginRequest({
    required this.authorizeUri,
    required this.redirectUri,
    this.state,
    this.stateTtlSeconds,
  });

  final Uri authorizeUri;
  final String redirectUri;
  final String? state;
  final int? stateTtlSeconds;
}

class StartHrmLoginUseCase {
  const StartHrmLoginUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  String get redirectUri => AppConfig.hrmOauthRedirectUri;

  Future<HrmLoginRequest> call() async {
    final data = await _authRepository.createOauthAuthorizeUrl(
      redirectUri: redirectUri,
    );
    final uri = Uri.tryParse(data.authorizeUrl);
    if (uri == null || !uri.hasScheme) {
      throw const FormatException('HRM login URL notogri.');
    }
    return HrmLoginRequest(
      authorizeUri: uri,
      redirectUri: redirectUri,
      state: data.state,
      stateTtlSeconds: data.stateTtlSeconds,
    );
  }
}
