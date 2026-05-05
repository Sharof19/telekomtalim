import 'package:uztelecom/application/use_cases/auth/get_valid_access_token_use_case.dart';

class BuildAuthorizedVideoHeadersUseCase {
  const BuildAuthorizedVideoHeadersUseCase({
    required GetValidAccessTokenUseCase getValidAccessToken,
  }) : _getValidAccessToken = getValidAccessToken;

  final GetValidAccessTokenUseCase _getValidAccessToken;

  Future<Map<String, String>> call() async {
    final token = await _getValidAccessToken();
    if (token == null || token.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }
}
