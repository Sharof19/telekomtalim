import 'package:uztelecom/core/utils/app_logger.dart';

DateTime? parseExamDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (error, stackTrace) {
    AppLogger.warning(
      'Failed to parse exam date.',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}
