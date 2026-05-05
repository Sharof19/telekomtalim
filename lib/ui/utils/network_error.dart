import 'package:uztelecom/core/errors/app_failure.dart';

bool isNoInternetError(Object error) {
  if (AppFailure.isNetworkError(error)) return true;

  final message = error.toString().toLowerCase();
  return message.contains('socketexception') ||
      message.contains('failed host lookup') ||
      message.contains('no address associated with hostname') ||
      message.contains('network is unreachable') ||
      message.contains('errno = 7') ||
      message.contains('enonet');
}
