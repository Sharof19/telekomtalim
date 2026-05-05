import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required http.Client client,
    required ApiClient apiClient,
  }) : _client = client,
       _apiClient = apiClient;

  final http.Client _client;
  final ApiClient _apiClient;

  Future<void> requestLogin({
    required String login,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.login(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw ApiClient.failureFromResponse(
      response,
      fallbackMessage: 'Login xatosi.',
    );
  }

  Future<OAuthAuthorizeData> createOauthAuthorizeUrl({
    required String redirectUri,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.oauthAuthorizeUrl(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({'redirect_uri': redirectUri}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = ApiClient.decodeObjectBody(response.body);
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      final url =
          data['authorize_url']?.toString() ??
          data['redirect_uri']?.toString() ??
          data['redirectUrl']?.toString() ??
          data['url']?.toString();
      if (url != null && url.isNotEmpty) {
        return OAuthAuthorizeData(
          authorizeUrl: url,
          state: data['state']?.toString(),
          stateTtlSeconds: int.tryParse(
            data['state_ttl_seconds']?.toString() ?? '',
          ),
        );
      }
      throw const ParsingFailure('HRM login URL topilmadi.');
    }

    throw ApiClient.failureFromResponse(
      response,
      fallbackMessage: 'HRM login URL yaratilmadi.',
    );
  }

  Future<String> exchangeOauthCallback({
    required String code,
    required String redirectUri,
    required String state,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.oauthCallbackExchange(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({
        'data': {'code': code, 'redirect_uri': redirectUri, 'state': state},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }

    throw ApiClient.failureFromResponse(
      response,
      fallbackMessage: 'HRM login yakunlanmadi.',
    );
  }

  Future<String> verifyCode({
    required String login,
    required String code,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.verifyCode(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({'login': login, 'code': code, 'client_type': 'mobile'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }

    throw ApiClient.failureFromResponse(
      response,
      fallbackMessage: 'Kod tasdiqlanmadi.',
    );
  }

  Future<void> resendCode({required String login}) async {
    final response = await _apiClient.post(
      AppEndpoints.resendCode(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({'login': login}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw ApiClient.failureFromResponse(
      response,
      fallbackMessage: 'Kod yuborilmadi.',
    );
  }

  Future<void> forgotPassword({required String phone}) async {
    final response = await _apiClient.post(
      AppEndpoints.forgotPassword(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({'phone': phone}),
    );

    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201, 202},
      fallbackMessage: 'Parolni tiklash kodi yuborilmadi.',
    );
  }

  Future<String> refreshToken({required String refreshToken}) async {
    final response = await _apiClient.post(
      AppEndpoints.refreshToken(),
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({'refresh': refreshToken, 'client_type': 'mobile'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }

    throw ApiClient.failureFromResponse(
      response,
      fallbackMessage: 'Tokenni yangilashda xatolik.',
    );
  }

  Future<void> createPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.createPassword(),
      authorized: true,
      headers: ApiClient.defaultAuthorizedJsonHeaders,
      body: jsonEncode({
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201, 202, 204},
      fallbackMessage: 'Parol yaratishda xatolik.',
    );
  }

  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.changePassword(),
      authorized: true,
      headers: ApiClient.defaultAuthorizedJsonHeaders,
      body: jsonEncode({
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201, 202, 204},
      fallbackMessage: 'Parolni o\'zgartirishda xatolik.',
    );
  }

  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    final http.Response response;
    try {
      response = await _client.post(
        AppEndpoints.logout(),
        headers: ApiClient.authorizedJsonHeaders(
          accessToken,
          headers: ApiClient.defaultAuthorizedJsonHeaders,
        ),
        body: jsonEncode({'refresh': refreshToken}),
      );
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure.fromObject(error, fallbackMessage: 'Logout xatosi.');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiClient.failureFromResponse(
        response,
        fallbackMessage: 'Logout xatosi.',
      );
    }
  }
}

class OAuthAuthorizeData {
  const OAuthAuthorizeData({
    required this.authorizeUrl,
    this.state,
    this.stateTtlSeconds,
  });

  final String authorizeUrl;
  final String? state;
  final int? stateTtlSeconds;
}
