import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env');
    _loaded = true;
  }

  static String get apiBaseUrl =>
      _normalizeBaseUrl(_read('API_BASE_URL', 'https://eduapi.uztelecom.uz'));

  static String get apiV1Path =>
      _normalizePath(_read('API_V1_PATH', '/api/v1'));

  static String get apiV1BaseUrl => '$apiBaseUrl$apiV1Path';

  static String get lrsBaseUrl =>
      _normalizeBaseUrl(_read('LRS_BASE_URL', 'https://lrs.uztelecom.uz'));

  static Uri apiV1Uri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = _trimLeadingSlash(path);
    final uri = Uri.parse('$apiV1BaseUrl/$normalizedPath');
    if (queryParameters == null) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  static Uri get connectivityProbeUri => Uri.parse('$apiBaseUrl/');

  static String? absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (_isAbsolute(path)) return path;
    if (path.startsWith('/')) return '$apiBaseUrl$path';
    return '$apiBaseUrl/$path';
  }

  static String? mediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (_isAbsolute(path)) return path;
    if (path.startsWith('/media/')) {
      return absoluteUrl(path);
    }
    final normalized = _trimLeadingSlash(path);
    return '$apiBaseUrl/media/$normalized';
  }

  static bool _isAbsolute(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  static String _read(String key, String fallback) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  static String _normalizeBaseUrl(String value) =>
      value.replaceFirst(RegExp(r'/$'), '');

  static String _normalizePath(String value) {
    final withLeadingSlash = value.startsWith('/') ? value : '/$value';
    return withLeadingSlash.replaceFirst(RegExp(r'/$'), '');
  }

  static String _trimLeadingSlash(String value) =>
      value.startsWith('/') ? value.substring(1) : value;
}
