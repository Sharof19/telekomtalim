import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/datasources/local/auth_local_data_source.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/datasources/remote/auth_remote_data_source.dart';

class AuthRepository {
  AuthRepository({http.Client? client, ApiClient? apiClient, bool? ownsClient})
    : _client = client ?? http.Client(),
      _ownsClient = ownsClient ?? client == null,
      _local = AuthLocalDataSource() {
    _remote = AuthRemoteDataSource(
      client: _client,
      apiClient: apiClient ?? ApiClient(client: _client),
    );
  }

  final http.Client _client;
  final bool _ownsClient;
  final AuthLocalDataSource _local;
  late final AuthRemoteDataSource _remote;
  static Future<String?>? _ongoingRefresh;
  static const _authErrorCodes = {401, 403, 498};

  Future<void> requestLogin({
    required String login,
    required String password,
  }) => _remote.requestLogin(login: login, password: password);

  Future<OAuthAuthorizeData> createOauthAuthorizeUrl({
    required String redirectUri,
  }) {
    return _remote.createOauthAuthorizeUrl(redirectUri: redirectUri);
  }

  Future<void> exchangeOauthCallback({
    required String code,
    required String redirectUri,
    required String state,
  }) async {
    final body = await _remote.exchangeOauthCallback(
      code: code,
      redirectUri: redirectUri,
      state: state,
    );
    await _handleAuthResponse(body);
  }

  Future<void> verifyCode({required String login, required String code}) async {
    final body = await _remote.verifyCode(login: login, code: code);
    await _handleAuthResponse(body);
  }

  Future<void> resendCode({required String login}) =>
      _remote.resendCode(login: login);

  Future<void> forgotPassword({required String phone}) {
    return _remote.forgotPassword(phone: phone);
  }

  Future<void> createPassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    return _remote.createPassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    return _remote.changePassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<String?> getValidAccessToken() async {
    final access = await _local.getAccessToken();
    final expiry = await _local.getAccessTokenExpiry();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (access != null && expiry != null && expiry - now > 60) {
      return access;
    }

    return _refreshAccessToken();
  }

  Future<http.Response> authorizedRequest({
    required Future<http.Response> Function(String token) request,
    bool retryOnAuthError = true,
  }) async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw const AuthFailure('Token topilmadi. Iltimos, qayta kiring.');
    }

    var response = await request(token);
    final shouldRefresh =
        _authErrorCodes.contains(response.statusCode) ||
        _isTokenInvalidResponse(response.body);
    if (retryOnAuthError && shouldRefresh) {
      try {
        final refreshed = await _refreshAccessToken();
        if (refreshed == null || refreshed.isEmpty) {
          await _clearTokens();
          throw const AuthFailure('Token eskirgan. Iltimos, qayta kiring.');
        }
        response = await request(refreshed);
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Authorized request refresh failed; clearing auth tokens.',
          error: error,
          stackTrace: stackTrace,
        );
        await _clearTokens();
        rethrow;
      }
    }

    return response;
  }

  bool _isTokenInvalidResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return false;

      final code = decoded['code']?.toString().toLowerCase();
      if (code == 'token_not_valid') return true;

      final detail = decoded['detail']?.toString().toLowerCase() ?? '';
      if (detail.contains('token') &&
          (detail.contains('expired') || detail.contains('not valid'))) {
        return true;
      }

      final messages = decoded['messages'];
      if (messages is List) {
        for (final item in messages) {
          if (item is! Map<String, dynamic>) continue;
          final message = item['message']?.toString().toLowerCase() ?? '';
          if (message.contains('token') &&
              (message.contains('expired') ||
                  message.contains('not valid') ||
                  message.contains('invalid'))) {
            return true;
          }
        }
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to parse auth error response.',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }

  Future<void> logout() async {
    final refresh = await _local.getRefreshToken();
    final access = await _local.getAccessToken();

    if (refresh != null &&
        refresh.isNotEmpty &&
        access != null &&
        access.isNotEmpty) {
      await _remote.logout(accessToken: access, refreshToken: refresh);
    }

    await _clearTokens();
  }

  Future<void> _clearTokens() => _local.clearTokens();

  Future<String?> _refreshAccessToken() async {
    final inFlight = _ongoingRefresh;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _refreshAccessTokenInternal();
    _ongoingRefresh = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_ongoingRefresh, refreshFuture)) {
        _ongoingRefresh = null;
      }
    }
  }

  Future<String?> _refreshAccessTokenInternal() async {
    final refresh = await _local.getRefreshToken();
    if (refresh == null) return null;

    final body = await _remote.refreshToken(refreshToken: refresh);
    final access = await _handleAuthResponse(body);
    return access ?? await _local.getAccessToken();
  }

  Future<String?> _handleAuthResponse(String body) async {
    final decoded = _decodeAuthBody(body);
    final data = decoded['data'] is Map<String, dynamic>
        ? decoded['data'] as Map<String, dynamic>
        : decoded;

    final access = data['access']?.toString();
    final refresh = data['refresh']?.toString();
    if (access == null || access.isEmpty) {
      return null;
    }

    final exp = _decodeExpiry(access);
    await _local.saveTokens(
      accessToken: access,
      refreshToken: refresh,
      expiry: exp,
    );
    return access;
  }

  Map<String, dynamic> _decodeAuthBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (error) {
      throw ParsingFailure(
        'Auth javob formatini o‘qib bo‘lmadi.',
        cause: error,
      );
    }
    throw const ParsingFailure('Auth javob formati noto‘g‘ri.');
  }

  int? _decodeExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, dynamic>;
      return payload['exp'] as int?;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to decode access token expiry.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
