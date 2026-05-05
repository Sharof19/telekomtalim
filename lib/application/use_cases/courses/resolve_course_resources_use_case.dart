import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/data/models/course_item.dart';

class CourseResourceUrls {
  const CourseResourceUrls({
    required this.photoUrl,
    required this.videoUrl,
    required this.contentUrl,
  });

  final String? photoUrl;
  final String? videoUrl;
  final String? contentUrl;
}

class ResolveCourseResourcesUseCase {
  const ResolveCourseResourcesUseCase();

  CourseResourceUrls call({required CourseItem item, CourseItem? fallback}) {
    return CourseResourceUrls(
      photoUrl: AppConfig.absoluteUrl(item.photo),
      videoUrl: _resolveVideoUrl(item),
      contentUrl: _resolveContentUrl(item, fallback: fallback),
    );
  }

  String normalizeLaunchUrl(String url) {
    return url.replaceAll(' ', '%20');
  }

  String? _resolveVideoUrl(CourseItem item) {
    final raw =
        item.mainVideo ??
        (_looksLikeVideo(item.filePath) ? item.filePath : null) ??
        (_looksLikeVideo(item.file) ? item.file : null);
    if (raw == null || raw.isEmpty) return null;
    return AppConfig.mediaUrl(raw) ?? AppConfig.absoluteUrl(raw);
  }

  String? _resolveContentUrl(CourseItem item, {CourseItem? fallback}) {
    final filePath = (item.filePath != null && item.filePath!.isNotEmpty)
        ? item.filePath
        : fallback?.filePath;
    final baseUrl = AppConfig.mediaUrl(filePath);
    final query = (item.fullQuery != null && item.fullQuery!.isNotEmpty)
        ? item.fullQuery
        : fallback?.fullQuery;
    if (baseUrl == null || baseUrl.isEmpty) return null;
    if (query == null || query.isEmpty) {
      return normalizeLaunchUrl(baseUrl);
    }
    return normalizeLaunchUrl(_appendRawQuery(baseUrl, query));
  }

  String _appendRawQuery(String baseUrl, String rawQuery) {
    final cleaned = rawQuery.startsWith('?') ? rawQuery.substring(1) : rawQuery;
    if (cleaned.isEmpty) return baseUrl;
    if (baseUrl.contains('?')) {
      if (baseUrl.endsWith('?') || baseUrl.endsWith('&')) {
        return '$baseUrl$cleaned';
      }
      return '$baseUrl&$cleaned';
    }
    return '$baseUrl?$cleaned';
  }

  bool _looksLikeVideo(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    return lower.contains('.mp4') ||
        lower.contains('.m3u8') ||
        lower.contains('.webm') ||
        lower.contains('.mov') ||
        lower.contains('.mkv');
  }
}
