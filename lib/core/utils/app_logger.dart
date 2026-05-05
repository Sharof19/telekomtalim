import 'dart:developer' as developer;

abstract final class AppLogger {
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'uztelecom',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
