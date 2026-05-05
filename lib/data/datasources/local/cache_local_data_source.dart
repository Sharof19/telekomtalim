import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uztelecom/core/utils/app_logger.dart';

class CacheCleanupPolicy {
  final Duration tempMaxAge;
  final Duration appCacheMaxAge;
  final int imageCacheMaximumSize;
  final int imageCacheMaximumBytes;

  const CacheCleanupPolicy({
    this.tempMaxAge = const Duration(days: 1),
    this.appCacheMaxAge = const Duration(days: 14),
    this.imageCacheMaximumSize = 200,
    this.imageCacheMaximumBytes = 80 << 20,
  });
}

class CacheLocalDataSource {
  static const CacheCleanupPolicy defaultPolicy = CacheCleanupPolicy();

  static Future<void> maintainOnStartup({
    CacheCleanupPolicy policy = defaultPolicy,
  }) async {
    await _deleteExpiredChildren(
      directoryFuture: getTemporaryDirectory(),
      maxAge: policy.tempMaxAge,
    );
    await _deleteExpiredChildren(
      directoryFuture: getApplicationCacheDirectory(),
      maxAge: policy.appCacheMaxAge,
    );

    try {
      PaintingBinding.instance.imageCache.maximumSize =
          policy.imageCacheMaximumSize;
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          policy.imageCacheMaximumBytes;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to configure image cache limits.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> _deleteExpiredChildren({
    required Future<Directory> directoryFuture,
    required Duration maxAge,
  }) async {
    try {
      final directory = await directoryFuture;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        return;
      }

      final cutoff = DateTime.now().subtract(maxAge);
      await for (final entity in directory.list(followLinks: false)) {
        try {
          final stat = await entity.stat();
          if (stat.modified.isAfter(cutoff)) continue;
          await entity.delete(recursive: true);
        } catch (error, stackTrace) {
          AppLogger.warning(
            'Failed to delete expired cache entry: ${entity.path}',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to clean expired cache directory.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
