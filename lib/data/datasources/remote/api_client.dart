import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/utils/app_logger.dart';

typedef AuthorizedRequestExecutor =
    Future<http.Response> Function({
      required Future<http.Response> Function(String token) request,
      bool retryOnAuthError,
    });

class ApiClient {
  static const Map<String, String> acceptJsonHeaders = {
    'accept': 'application/json',
  };
  static const Map<String, String> defaultJsonHeaders = {
    'Content-Type': 'application/json',
  };
  static const Map<String, String> defaultAuthorizedJsonHeaders =
      defaultJsonHeaders;

  ApiClient({
    required http.Client client,
    AuthorizedRequestExecutor? authorizedRequest,
  }) : _client = client,
       _authorizedRequest = authorizedRequest;

  final http.Client _client;
  final AuthorizedRequestExecutor? _authorizedRequest;

  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    bool authorized = false,
    bool retryOnAuthError = true,
  }) async {
    if (!authorized) {
      return _runRequest(
        () => _client.get(uri, headers: _mergeHeaders(headers: headers)),
      );
    }

    final authorizedRequest = _authorizedRequest;
    if (authorizedRequest == null) {
      throw StateError('Authorized request handler is not configured.');
    }

    return _runRequest(
      () => authorizedRequest(
        retryOnAuthError: retryOnAuthError,
        request: (token) => _client.get(
          uri,
          headers: _mergeHeaders(headers: headers, bearerToken: token),
        ),
      ),
    );
  }

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool authorized = false,
    bool retryOnAuthError = true,
  }) async {
    if (!authorized) {
      return _runRequest(
        () => _client.post(
          uri,
          headers: _mergeHeaders(headers: headers),
          body: body,
          encoding: encoding,
        ),
      );
    }

    final authorizedRequest = _authorizedRequest;
    if (authorizedRequest == null) {
      throw StateError('Authorized request handler is not configured.');
    }

    return _runRequest(
      () => authorizedRequest(
        retryOnAuthError: retryOnAuthError,
        request: (token) => _client.post(
          uri,
          headers: _mergeHeaders(headers: headers, bearerToken: token),
          body: body,
          encoding: encoding,
        ),
      ),
    );
  }

  Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool authorized = false,
    bool retryOnAuthError = true,
  }) async {
    if (!authorized) {
      return _runRequest(
        () => _client.patch(
          uri,
          headers: _mergeHeaders(headers: headers),
          body: body,
          encoding: encoding,
        ),
      );
    }

    final authorizedRequest = _authorizedRequest;
    if (authorizedRequest == null) {
      throw StateError('Authorized request handler is not configured.');
    }

    return _runRequest(
      () => authorizedRequest(
        retryOnAuthError: retryOnAuthError,
        request: (token) => _client.patch(
          uri,
          headers: _mergeHeaders(headers: headers, bearerToken: token),
          body: body,
          encoding: encoding,
        ),
      ),
    );
  }

  static String? extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final detail = decoded['detail']?.toString();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to extract API error message.',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  static void ensureSuccess(
    http.Response response, {
    Set<int> okStatuses = const {200},
    required String fallbackMessage,
  }) {
    if (okStatuses.contains(response.statusCode)) return;
    throw failureFromResponse(response, fallbackMessage: fallbackMessage);
  }

  static Map<String, dynamic> decodeObjectBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ParsingFailure('Javob formatini o‘qib bo‘lmadi.', cause: error);
    }
    throw const ParsingFailure('Javob formati noto‘g‘ri.');
  }

  static Map<String, dynamic> dataMap(Map<String, dynamic> body) {
    return body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  static List<dynamic> dataList(Map<String, dynamic> body) {
    return body['data'] as List<dynamic>? ?? const <dynamic>[];
  }

  static void ensureBodyStatusOk(
    Map<String, dynamic> body, {
    required String fallbackMessage,
  }) {
    if (body['status']?.toString() != 'error') return;
    throw ServerFailure(body['message']?.toString() ?? fallbackMessage);
  }

  static Uri? extractNextPageUri(Map<String, dynamic> body) {
    final pagination = body['pagination'] as Map<String, dynamic>?;
    final next = pagination?['next']?.toString();
    if (next == null || next.isEmpty) return null;
    return Uri.parse(next);
  }

  static Map<String, String> authorizedJsonHeaders(
    String token, {
    Map<String, String>? headers,
  }) {
    return {
      ...acceptJsonHeaders,
      ...?headers,
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> jsonHeaders({Map<String, String>? headers}) {
    return {...acceptJsonHeaders, ...defaultJsonHeaders, ...?headers};
  }

  static AppFailure failureFromResponse(
    http.Response response, {
    required String fallbackMessage,
  }) {
    final message = extractMessage(response.body) ?? fallbackMessage;
    if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 498) {
      return AuthFailure(message);
    }
    return ServerFailure(message, statusCode: response.statusCode);
  }

  Future<http.Response> _runRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure.fromObject(
        error,
        fallbackMessage: 'So‘rovni bajarishda xatolik yuz berdi.',
      );
    }
  }

  Map<String, String> _mergeHeaders({
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    return {
      ...acceptJsonHeaders,
      ...?headers,
      if (bearerToken != null && bearerToken.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };
  }
}
