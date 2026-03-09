import 'package:flutter/material.dart';
import 'package:uztelecom/domain/services/courses_service.dart';
import 'package:uztelecom/domain/services/my_courses_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/darslar_page.dart';
import 'package:uztelecom/ui/pages/no_internet_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class MyCoursesPage extends StatefulWidget {
  final bool embedded;

  const MyCoursesPage({super.key, this.embedded = false});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  final MyCoursesService _service = MyCoursesService();
  late Future<List<MyCourseItem>> _future;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchMyCourses();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchMyCourses();
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
          tr(context, uz: 'Kurslarim', ru: 'Мои курсы'),
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
      child: FutureBuilder<List<MyCourseItem>>(
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
              return _MyCourseCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _MyCourseCard extends StatelessWidget {
  final MyCourseItem item;

  const _MyCourseCard({required this.item});

  String? _absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return 'https://eduapi.uztelecom.uz$path';
    return 'https://eduapi.uztelecom.uz/$path';
  }

  String? _durationLabel(BuildContext context) {
    final raw = item.duration?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  CourseItem _toCourseItem(MyCourseItem item) {
    return CourseItem(
      id: item.id,
      title: item.title,
      description: item.description,
      status: item.status,
      photo: item.photo,
      mainVideo: item.mainVideo,
      filePath: item.filePath,
      launchUrl: item.launchUrl,
      fullQuery: item.fullQuery,
      duration: item.duration,
      language: item.language,
      audience: item.audience,
      trainerName: item.trainerName,
      listenerCount: item.listenerCount,
    );
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

  double _progressPercent() {
    final percent = item.progressPercent;
    if (percent != null) {
      return percent.clamp(0, 100).toDouble();
    }
    final completed = item.completedActivities;
    final total = item.totalActivities;
    if (completed != null && total != null && total > 0) {
      return ((completed / total) * 100).clamp(0, 100).toDouble();
    }
    return 0;
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
    final progress = _progressPercent();
    final completed = item.completedActivities;
    final total = item.totalActivities;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConnectivityGate(
              child: CourseInfoPage(
                courseId: item.id,
                initialItem: _toCourseItem(item),
                useMyCoursesDetailApi: true,
              ),
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
                    item.title ?? tr(context, uz: 'Kurs', ru: 'Курс'),
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
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (progress / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: isDark
                          ? const Color(0xFF2D4258)
                          : const Color(0xFFE5EAF3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2F6BFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    completed != null && total != null && total > 0
                        ? '$completed/$total '
                              '${tr(context, uz: 'aktiv', ru: 'активностей')} • '
                              '${progress.toStringAsFixed(1)}%'
                        : '${progress.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  const _MetaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final bg = isDark
        ? const Color(0xFF0B57A4)
        : scheme.secondary.withOpacity(0.12);
    final textColor = isDark ? Colors.white : scheme.secondary;
    return Container(
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
