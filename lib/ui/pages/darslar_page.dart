import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:uztelecom/domain/services/courses_service.dart';
import 'package:uztelecom/domain/services/login_service.dart';
import 'package:uztelecom/domain/services/my_courses_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';
import 'package:uztelecom/ui/pages/no_internet_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/utils/network_error.dart';

class CoursesPage extends StatefulWidget {
  final bool embedded;

  const CoursesPage({super.key, this.embedded = false});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

@Deprecated('Use CoursesPage')
class DarslarPage extends CoursesPage {
  const DarslarPage({super.key, super.embedded});
}

class _CoursesPageState extends State<CoursesPage> {
  final CoursesService _service = CoursesService();
  late Future<List<CourseItem>> _future;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchCourses();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchCourses();
    });
  }

  void _showOfflinePage() {
    if (_offlinePushed) return;
    _offlinePushed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => NoInternetPage(
                onRetry: () {
                  Navigator.of(context).pop();
                  _offlinePushed = false;
                  _reload();
                },
              ),
            ),
          )
          .then((_) {
            _offlinePushed = false;
          });
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConnectivityGate(child: NotificationsPage()),
      ),
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final body = _buildBody(context);
    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onBackground,
        title: Text(
          tr(context, uz: 'Kurslar', ru: 'Курсы'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, uz: 'Xabarlar', ru: 'Уведомления'),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: FutureBuilder<List<CourseItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }
          if (snapshot.hasError) {
            final error = snapshot.error!;
            if (isNoInternetError(error)) {
              _showOfflinePage();
              return const SizedBox.shrink();
            }
            return _EmptyState(
              message: tr(
                context,
                uz: 'Kurslarni yuklashda xatolik. Qayta urinib ko\'ring.',
                ru: 'Не удалось загрузить курсы. Попробуйте снова.',
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _EmptyState(
              message: tr(
                context,
                uz: 'Kurslar hozircha mavjud emas.',
                ru: 'Курсы пока недоступны.',
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _CourseCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseItem item;

  const _CourseCard({required this.item});

  String? _absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return 'https://eduapi.uztelecom.uz$path';
  }

  String? _durationLabel(BuildContext context) {
    if (item.hours != null) {
      return tr(context, uz: '${item.hours} soat', ru: '${item.hours} ч');
    }
    final raw = item.duration?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Widget _statItem({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF12273A) : Colors.white;
    final border = isDark ? const Color(0xFF1F3D5A) : const Color(0xFFE3E8F0);
    final thumbBg = isDark ? const Color(0xFF0F2F4A) : const Color(0xFFF1F4F8);
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2836);
    final muted = isDark ? const Color(0xFFB9C9DB) : const Color(0xFF7C8798);
    final actionColor = isDark
        ? const Color(0xFF7FB1FF)
        : const Color(0xFF2F6BFF);
    final photoUrl = _absoluteUrl(item.photo);
    final audience = item.audience?.trim();
    final trainerName = item.trainerName?.trim();
    final durationLabel = _durationLabel(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConnectivityGate(
              child: CourseInfoPage(courseId: item.id, initialItem: item),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: thumbBg,
                      child: photoUrl == null
                          ? Icon(
                              Icons.image_not_supported,
                              color: muted,
                              size: 30,
                            )
                          : Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_not_supported,
                                color: muted,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.45, 0.75, 1],
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.12),
                            Colors.black.withOpacity(0.62),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (audience != null && audience.isNotEmpty)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      left: 10,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC12253D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            audience,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      if (item.listenerCount != null)
                        _statItem(
                          icon: Icons.people_alt_outlined,
                          text: '${item.listenerCount}',
                          iconColor: muted,
                          textColor: muted,
                        ),
                      if (durationLabel != null && durationLabel.isNotEmpty)
                        _statItem(
                          icon: Icons.access_time_filled_rounded,
                          text: durationLabel,
                          iconColor: muted,
                          textColor: muted,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title ??
                        item.courseName ??
                        tr(context, uz: 'Kurs', ru: 'Курс'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (trainerName != null && trainerName.isNotEmpty)
                    Text(
                      trainerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      item.status ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr(
                          context,
                          uz: "Kursni ko'rish",
                          ru: 'Посмотреть курс',
                        ),
                        style: TextStyle(
                          color: actionColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: actionColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _MetaChip({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final bg = isDark
        ? const Color(0xFF0B57A4)
        : scheme.secondary.withOpacity(0.12);
    final textColor = isDark ? Colors.white : scheme.secondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onBackground.withOpacity(0.6);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: 15),
      ),
    );
  }
}

class CourseInfoPage extends StatefulWidget {
  final int courseId;
  final CourseItem? initialItem;
  final bool useMyCoursesDetailApi;

  const CourseInfoPage({
    super.key,
    required this.courseId,
    this.initialItem,
    this.useMyCoursesDetailApi = false,
  });

  @override
  State<CourseInfoPage> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> {
  VideoPlayerController? _videoController;
  final LoginService _loginService = LoginService();
  final CoursesService _coursesService = CoursesService();
  final MyCoursesService _myCoursesService = MyCoursesService();
  bool _requestSubmitted = false;
  bool _playRequested = false;
  String? _videoError;
  late final Future<CourseItem> _detailFuture;

  String? _absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return 'https://eduapi.uztelecom.uz$path';
    return 'https://eduapi.uztelecom.uz/$path';
  }

  String? _resourceUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    if (path.startsWith('/media/')) {
      return 'https://eduapi.uztelecom.uz$path';
    }
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return 'https://eduapi.uztelecom.uz/media/$normalized';
  }

  String? _resolveVideoUrl(CourseItem item) {
    final raw =
        item.mainVideo ??
        (_looksLikeVideo(item.filePath) ? item.filePath : null) ??
        (_looksLikeVideo(item.file) ? item.file : null);
    if (raw == null || raw.isEmpty) return null;
    return _resourceUrl(raw) ?? _absoluteUrl(raw);
  }

  String? _resolveContentUrl(CourseItem item) {
    final fallback = widget.initialItem;
    final filePath = (item.filePath != null && item.filePath!.isNotEmpty)
        ? item.filePath
        : fallback?.filePath;
    final baseUrl = _resourceUrl(filePath);
    final query = (item.fullQuery != null && item.fullQuery!.isNotEmpty)
        ? item.fullQuery
        : fallback?.fullQuery;
    if (baseUrl == null || baseUrl.isEmpty) return null;
    if (query == null || query.isEmpty) {
      return _normalizeUrlForLaunch(baseUrl);
    }
    return _normalizeUrlForLaunch(_appendRawQuery(baseUrl, query));
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

  String _normalizeUrlForLaunch(String url) {
    // Backend may return "auth=Bearer <token>" with a raw space; encode only spaces.
    return url.replaceAll(' ', '%20');
  }

  Future<void> _openExternalResource(String url) async {
    final safeUrl = _normalizeUrlForLaunch(url);
    final uri = Uri.tryParse(safeUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              uz: "Resurs havolasi noto'g'ri.",
              ru: 'Некорректная ссылка ресурса.',
            ),
          ),
        ),
      );
      return;
    }
    debugPrint('SCORM launch URL: $safeUrl');
    debugPrint(
      'SCORM url has query: ${uri.hasQuery} (len=${uri.query.length})',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              uz: "Resursni ochib bo'lmadi.",
              ru: 'Не удалось открыть ресурс.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openCourseResource(CourseItem displayedItem) async {
    final contentUrl = _resolveContentUrl(displayedItem);

    if (contentUrl == null || contentUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              uz: "Resurs havolasi topilmadi.",
              ru: 'Ссылка на ресурс не найдена.',
            ),
          ),
        ),
      );
      return;
    }

    await _openExternalResource(contentUrl);
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

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.useMyCoursesDetailApi
        ? _myCoursesService.fetchCourseDetail(widget.courseId)
        : _coursesService.fetchCourseDetail(widget.courseId);
  }

  Future<void> _initVideo(CourseItem item) async {
    if (_videoController != null) return;
    final videoUrl = _resolveVideoUrl(item);
    if (videoUrl == null) return;
    try {
      final token = await _loginService.getValidAccessToken();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: headers,
      );
      controller.addListener(() {
        final error = controller.value.errorDescription;
        if (error != null && error.isNotEmpty && mounted) {
          if (_videoError != error) {
            setState(() => _videoError = error);
          }
        }
      });
      _videoController = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
      if (_playRequested) {
        await controller.play();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _videoError = e.toString());
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _loginService.dispose();
    _coursesService.dispose();
    _myCoursesService.dispose();
    super.dispose();
  }

  Future<void> _openFullscreen() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VideoFullscreenPage(controller: controller),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = isDark ? Colors.white : scheme.onBackground;
    final textMuted = isDark
        ? const Color(0xFFB9C9DB)
        : scheme.onBackground.withOpacity(0.6);
    final infoCardBg = isDark ? const Color(0xFF2A4D6E) : scheme.surface;
    final infoCardBorder = isDark
        ? const Color(0xFF3C6A91)
        : Theme.of(context).dividerColor;
    final infoDivider = isDark
        ? const Color(0xFF3C6A91)
        : Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: scheme.onBackground,
        title: Text(
          tr(context, uz: 'Kurs maʼlumotlari', ru: 'Информация о курсе'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<CourseItem>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final item = snapshot.data ?? widget.initialItem;
          if (item == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return Center(
              child: Text(
                tr(
                  context,
                  uz: 'Kurs ma\'lumotlarini yuklashda xatolik.',
                  ru: 'Не удалось загрузить данные курса.',
                ),
                style: TextStyle(color: textPrimary.withOpacity(0.8)),
              ),
            );
          }

          _initVideo(item);
          final photoUrl = _absoluteUrl(item.photo);
          final contentUrl = _resolveContentUrl(item);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_videoController != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.isInitialized
                          ? _videoController!.value.aspectRatio
                          : 16 / 9,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_videoError != null)
                            Center(
                              child: Text(
                                tr(
                                  context,
                                  uz: 'Video yuklanmadi.',
                                  ru: 'Видео не загрузилось.',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (_videoController!.value.isInitialized)
                            VideoPlayer(_videoController!)
                          else
                            Center(
                              child: CircularProgressIndicator(
                                color: scheme.primary,
                              ),
                            ),
                          if (_videoError == null)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_videoController == null) return;
                                  if (!_videoController!.value.isInitialized) {
                                    setState(() {
                                      _playRequested = true;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    if (_videoController!.value.isPlaying) {
                                      _videoController!.pause();
                                    } else {
                                      _videoController!.play();
                                    }
                                  });
                                },
                                child: Stack(
                                  children: [
                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      opacity:
                                          (_videoController!.value.isPlaying ||
                                              _playRequested)
                                          ? 0
                                          : 1,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: const BoxDecoration(
                                            color: Color(0x99000000),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 44,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      right: 10,
                                      bottom: 0,
                                      child: _VideoControls(
                                        controller: _videoController!,
                                        onFullscreen: _openFullscreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(photoUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  item.title ??
                      item.courseName ??
                      tr(context, uz: 'Kurs', ru: 'Курс'),
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((item.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (item.hours != null)
                      _MetaChip(text: '${item.hours} soat'),
                    if (item.days != null) _MetaChip(text: '${item.days} kun'),
                    if ((item.status ?? '').isNotEmpty)
                      _MetaChip(text: item.status!),
                    if ((item.duration ?? '').isNotEmpty)
                      _MetaChip(text: 'Sana: ${item.duration}'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: infoCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: infoCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.emoji_objects, color: Color(0xFF2EC5FF)),
                          SizedBox(width: 8),
                          Text(
                            'Nimani o‘rganasiz?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _LearningPoint(
                        text:
                            "Kurs mavzusini to'liq tushunish va qo'llay olish",
                      ),
                      const _LearningPoint(
                        text: "Amaliy ko'nikmalar va tajriba olish",
                      ),
                      const _LearningPoint(
                        text: "Real loyihalarda ishlash qobiliyati",
                      ),
                      const _LearningPoint(
                        text: "Professional darajada bilim olish",
                      ),
                      const _LearningPoint(
                        text: "Kursni tugatgandan so'ng sertifikat olish",
                      ),
                      const SizedBox(height: 14),
                      Divider(color: infoDivider, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.play_circle_fill,
                              title: 'Video darslar',
                              subtitle: "HD sifatli video materiallar",
                              color: Color(0xFF2E6FB7),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.verified_rounded,
                              title: 'Sertifikat',
                              subtitle: "Kursni tugatgach darhol",
                              color: Color(0xFF2FA97E),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.assignment_rounded,
                              title: 'Amaliy topshiriqlar',
                              subtitle: "Real loyihalar bilan ishlash",
                              color: Color(0xFF7A4FD6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (contentUrl != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _openCourseResource(item);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Resurslar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white
                                : const Color(0xFF2F80FF),
                            side: const BorderSide(color: Color(0xFF1F4C74)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!widget.useMyCoursesDetailApi) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: _requestSubmitted
                            ? const LinearGradient(
                                colors: [Color(0xFF6F86A1), Color(0xFF879CB3)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF0B57A4), Color(0xFF0B57A4)],
                              ),
                      ),
                      child: ElevatedButton(
                        onPressed: _requestSubmitted
                            ? null
                            : () {
                                setState(() {
                                  _requestSubmitted = true;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _requestSubmitted
                              ? 'Murojaat qoldirildi'
                              : 'Murojaat qoldirish',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onBackground.withOpacity(0.6);
    if (value == null || value!.trim().isEmpty || value == '-') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onFullscreen;

  const _VideoControls({required this.controller, this.onFullscreen});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final duration = value.duration;
        final position = value.position;
        final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
        final posMs = position.inMilliseconds.clamp(0, maxMs);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: const Color(0xFF2F80FF),
                  size: 20,
                ),
                onPressed: () {
                  if (value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(position),
                style: const TextStyle(color: Color(0xFF2F80FF), fontSize: 11),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: posMs.toDouble(),
                    min: 0,
                    max: maxMs.toDouble(),
                    onChanged: (v) {
                      controller.seekTo(Duration(milliseconds: v.toInt()));
                    },
                    activeColor: const Color(0xFF2F80FF),
                    inactiveColor: const Color(0x332F80FF),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(duration),
                style: const TextStyle(color: Color(0x992F80FF), fontSize: 11),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.volume_up, color: Color(0xFF2F80FF), size: 18),
              const SizedBox(width: 6),
              if (onFullscreen != null)
                InkWell(
                  onTap: onFullscreen,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.fullscreen,
                      color: Color(0xFF2F80FF),
                      size: 26,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _VideoFullscreenPage extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoFullscreenPage({required this.controller});

  @override
  State<_VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<_VideoFullscreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.isInitialized
                    ? controller.value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(controller),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: _VideoControls(
                controller: controller,
                onFullscreen: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningPoint extends StatelessWidget {
  final String text;

  const _LearningPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onBackground.withOpacity(0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2ED573), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF244563) : const Color(0xFFF1F4FA);
    final border = isDark
        ? const Color(0xFF335C80)
        : Theme.of(context).dividerColor;
    final titleColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onBackground;
    final subtitleColor = isDark
        ? const Color(0xFFB9C9DB)
        : Theme.of(context).colorScheme.onBackground.withOpacity(0.6);
    return Container(
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: subtitleColor, fontSize: 9),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
