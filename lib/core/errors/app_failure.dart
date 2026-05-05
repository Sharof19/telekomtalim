import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

abstract class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  static AppFailure fromObject(
    Object error, {
    String fallbackMessage = 'Kutilmagan xatolik yuz berdi.',
  }) {
    if (error is AppFailure) return error;
    if (isNetworkError(error)) {
      return NetworkFailure(
        'Internet aloqasini tekshirib qayta urinib ko‘ring.',
      );
    }
    if (error is FormatException || error is TypeError) {
      return ParsingFailure('Ma\'lumotlarni o‘qishda xatolik.', cause: error);
    }
    return UnknownFailure(fallbackMessage, cause: error);
  }

  static bool isNetworkError(Object error) {
    if (error is NetworkFailure) return true;
    if (error is SocketException || error is TimeoutException) return true;
    if (error is http.ClientException) return true;

    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated with hostname') ||
        message.contains('network is unreachable') ||
        message.contains('errno = 7') ||
        message.contains('enonet') ||
        message.contains('connection refused') ||
        message.contains('connection reset');
  }

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.cause});
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.cause});
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode, super.cause});

  final int? statusCode;
}

class ParsingFailure extends AppFailure {
  const ParsingFailure(super.message, {super.cause});
}

class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message, {super.cause});
}

String appFailureMessage(Object error) {
  if (error is AppFailure) return error.message;
  final raw = error.toString();
  return raw.startsWith('Exception: ')
      ? raw.replaceFirst('Exception: ', '')
      : raw;
}
