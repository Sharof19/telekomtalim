import 'package:flutter/material.dart';
import 'package:uztelecom/domain/services/dashboard_service.dart';
import 'package:uztelecom/domain/services/my_courses_service.dart';
import 'package:uztelecom/domain/services/profile_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/certificates_page.dart';
import 'package:uztelecom/ui/pages/darslar_page.dart';
import 'package:uztelecom/ui/pages/my_courses_page.dart';
import 'package:uztelecom/ui/pages/no_internet_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DashboardService _dashboardService = DashboardService();
  final MyCoursesService _myCoursesService = MyCoursesService();
  final ProfileService _profileService = ProfileService();
  late Future<_MainDashboardData> _future;
  String _appBarName = '';
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _seedAppBarName();
    _future = _load();
  }

  @override
  void dispose() {
    _dashboardService.dispose();
    _myCoursesService.dispose();
    _profileService.dispose();
    super.dispose();
  }

  Future<void> _seedAppBarName() async {
    try {
      final cached = await _profileService.getCachedProfile();
      final name = cached?.fullName.trim() ?? '';
      if (!mounted || name.isEmpty) return;
      setState(() => _appBarName = name);
    } catch (_) {}
  }

  Future<_MainDashboardData> _load() async {
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);
    final startDate = endDate.subtract(const Duration(days: 6));

    final summary = await _dashboardService.fetchSummary(
      startDate: startDate,
      endDate: endDate,
      days: 7,
    );

    String fullName = '';
    try {
      fullName = (await _profileService.fetchProfile(
        forceRefresh: false,
      )).fullName;
    } catch (_) {
      final cachedProfile = await _profileService.getCachedProfile();
      fullName = cachedProfile?.fullName ?? '';
    }
    fullName = fullName.trim();
    if (fullName.isNotEmpty) {
      _appBarName = fullName;
    }

    DashboardProgress? progress;
    DashboardTimeStats? timeStats;
    final coursePhotoById = <int, String>{};
    final summaryById = <int, DashboardCurrentCourse>{
      for (final c in summary.currentCourses) c.courseId: c,
    };
    List<DashboardCurrentCourse> currentCourses = [];
    List<MyCourseItem> myCourses = [];

    try {
      myCourses = await _myCoursesService.fetchMyCourses();
      for (final c in myCourses) {
        final photo = _absoluteUrl(c.photo);
        if (photo != null && photo.isNotEmpty) {
          coursePhotoById[c.id] = photo;
        }
      }
    } catch (_) {}

    if (myCourses.isNotEmpty) {
      final items = await Future.wait<DashboardCurrentCourse?>(
        myCourses.map((c) async {
          if (c.id <= 0) return null;

          var progressPercent =
              c.progressPercent ?? summaryById[c.id]?.progressPercent ?? 0;
          try {
            final courseProgress = await _dashboardService.fetchProgress(
              courseId: c.id,
            );
            progressPercent = courseProgress.overallProgressPercent;
          } catch (_) {}

          final fallback = summaryById[c.id];
          final completed =
              c.completedActivities ?? fallback?.completedActivities ?? 0;
          final total = c.totalActivities ?? fallback?.totalActivities ?? 0;
          final name = (c.title ?? '').trim();

          return DashboardCurrentCourse(
            courseId: c.id,
            courseName: name.isNotEmpty ? name : 'Kurs #${c.id}',
            progressPercent: progressPercent,
            completedActivities: completed,
            totalActivities: total,
            isFinished: fallback?.isFinished ?? (progressPercent >= 100),
          );
        }),
      );
      currentCourses = items.whereType<DashboardCurrentCourse>().toList();
    }

    if (currentCourses.isEmpty) {
      currentCourses = summary.currentCourses;
    }

    for (final current in currentCourses) {
      if (coursePhotoById[current.courseId] != null) continue;
      try {
        final detail = await _myCoursesService.fetchCourseDetail(
          current.courseId,
        );
        final photo = _absoluteUrl(detail.photo);
        if (photo != null && photo.isNotEmpty) {
          coursePhotoById[current.courseId] = photo;
        }
      } catch (_) {}
    }

    final firstCourseId = currentCourses.isNotEmpty
        ? currentCourses.first.courseId
        : null;

    if (firstCourseId != null && firstCourseId > 0) {
      final responses = await Future.wait<dynamic>([
        _dashboardService.fetchProgress(courseId: firstCourseId),
        _dashboardService.fetchTimeStats(
          startDate: startDate,
          endDate: endDate,
          courseId: firstCourseId,
        ),
      ]);
      progress = responses[0] as DashboardProgress;
      timeStats = responses[1] as DashboardTimeStats;
    }

    return _MainDashboardData(
      fullName: fullName,
      summary: summary,
      currentCourses: currentCourses,
      progress: progress,
      timeStats: timeStats,
      coursePhotoById: coursePhotoById,
    );
  }

  String? _absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) return 'https://eduapi.uztelecom.uz$path';
    return 'https://eduapi.uztelecom.uz/$path';
  }

  void _reload() {
    setState(() {
      _future = _load();
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

  void _onNotificationsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConnectivityGate(child: NotificationsPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final onBg = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: onBg,
        toolbarHeight: 86,
        titleSpacing: 14,
        title: _MainAppBarContent(future: _future, fallbackName: _appBarName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              onPressed: _onNotificationsTap,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, uz: 'Xabarlar', ru: 'Уведомления'),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_MainDashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            final error = snapshot.error!;
            if (isNoInternetError(error)) {
              _showOfflinePage();
              return const SizedBox.shrink();
            }
            return _DashboardErrorCard(
              message: tr(
                context,
                uz: "Dashboard ma'lumotlarini yuklab bo'lmadi.",
                ru: 'Не удалось загрузить данные dashboard.',
              ),
              onRetry: _reload,
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return _DashboardErrorCard(
              message: tr(
                context,
                uz: "Dashboard ma'lumotlari topilmadi.",
                ru: 'Данные dashboard не найдены.',
              ),
              onRetry: _reload,
            );
          }
          return _MainDashboardView(data: data, onRefresh: _reload);
        },
      ),
    );
  }
}

class _MainDashboardView extends StatelessWidget {
  final _MainDashboardData data;
  final VoidCallback onRefresh;

  const _MainDashboardView({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        data.progress?.overallProgressPercent ??
        _calcOverallProgress(data.currentCourses);
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final cardWidth = (constraints.maxWidth - spacing) / 2;
                final cards = [
                  _MiniStatCard(
                    title: tr(context, uz: 'Tugallangan', ru: 'Завершено'),
                    value: '${data.summary.completedCoursesCount}',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF16A34A),
                  ),
                  _MiniStatCard(
                    title: tr(
                      context,
                      uz: 'Faol kurslar',
                      ru: 'Активные курсы',
                    ),
                    value: '${data.summary.activeCoursesCount}',
                    icon: Icons.menu_book_outlined,
                    iconColor: const Color(0xFF2563EB),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectivityGate(child: MyCoursesPage()),
                        ),
                      );
                    },
                  ),
                  _MiniStatCard(
                    title: tr(
                      context,
                      uz: 'Olingan sertifikatlar',
                      ru: 'Полученные сертификаты',
                    ),
                    value: '0',
                    icon: Icons.workspace_premium_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectivityGate(child: CertificatesPage()),
                        ),
                      );
                    },
                  ),
                  _MiniStatCard(
                    title: tr(
                      context,
                      uz: 'Umumiy progress',
                      ru: 'Общий прогресс',
                    ),
                    value: '${progressPercent.toStringAsFixed(1)}%',
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF7C3AED),
                  ),
                ];
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: cards
                      .map((card) => SizedBox(width: cardWidth, child: card))
                      .toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.zero,
            child: _WeeklyTimeCard(days: data.timeStats?.days ?? const []),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.zero,
            child: _CurrentCoursesCard(
              courses: data.currentCourses,
              photoByCourseId: data.coursePhotoById,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainAppBarContent extends StatelessWidget {
  final Future<_MainDashboardData> future;
  final String fallbackName;

  const _MainAppBarContent({required this.future, required this.fallbackName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MainDashboardData>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final remoteName = data?.fullName.trim() ?? '';
        final localName = fallbackName.trim();
        final name = remoteName.isNotEmpty
            ? remoteName
            : (localName.isNotEmpty
                  ? localName
                  : tr(context, uz: 'Foydalanuvchi', ru: 'Пользователь'));
        return _WelcomeCard(name: name);
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;

  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF11223A);
    final textMuted = isDark
        ? const Color(0xFFB4C1CF)
        : const Color(0xFF5F738D);

    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFF4B72F6),
          child: Text(
            name.isNotEmpty ? name.characters.first.toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tr(context, uz: 'Xush kelibsiz!', ru: 'Добро пожаловать!'),
                style: TextStyle(
                  color: textMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyTimeCard extends StatelessWidget {
  final List<DashboardDayStat> days;

  const _WeeklyTimeCard({required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162333) : Colors.white;
    final border = isDark ? const Color(0xFF243548) : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final muted = isDark ? const Color(0xFF9BA8B7) : const Color(0xFF6B7280);

    final byDate = {for (final d in days) d.date: d.total};
    final now = DateTime.now();
    final bars = List.generate(7, (i) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      final dateKey =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return _BarPoint(
        label: _weekday2(context, d.weekday),
        value: byDate[dateKey] ?? 0,
      );
    });
    final maxValue = bars.fold<int>(
      0,
      (max, e) => e.value > max ? e.value : max,
    );
    final safeMax = maxValue <= 0 ? 1 : maxValue;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x120B1A33),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr(
                    context,
                    uz: 'Haftalik faollik',
                    ru: 'Недельная активность',
                  ),
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 108,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                final ratio = bar.value / safeMax;
                final height = 14 + (ratio * 62);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 20,
                        height: height,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bar.label,
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162333) : Colors.white;
    final border = isDark ? const Color(0xFF243548) : const Color(0xFFE3E9F2);
    final titleColor = isDark
        ? const Color(0xFF9FB2C8)
        : const Color(0xFF506784);
    final valueColor = isDark ? Colors.white : const Color(0xFF0D1B36);
    final iconBg = isDark
        ? iconColor.withValues(alpha: 0.22)
        : iconColor.withValues(alpha: 0.14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 118,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x120B1A33),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentCoursesCard extends StatelessWidget {
  final List<DashboardCurrentCourse> courses;
  final Map<int, String> photoByCourseId;

  const _CurrentCoursesCard({
    required this.courses,
    required this.photoByCourseId,
  });

  void _openCourseDetail(BuildContext context, int courseId) {
    if (courseId <= 0) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConnectivityGate(
          child: CourseInfoPage(
            courseId: courseId,
            useMyCoursesDetailApi: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162333) : Colors.white;
    final border = isDark ? const Color(0xFF243548) : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final muted = isDark ? const Color(0xFF9FB2C8) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x120B1A33),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, uz: 'Joriy kurslar', ru: 'Текущие курсы'),
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (courses.isEmpty)
            Text(
              tr(
                context,
                uz: "Hozircha joriy kurs yo'q.",
                ru: 'Пока нет текущих курсов.',
              ),
              style: TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ...courses.take(3).map((course) {
            final photoUrl = photoByCourseId[course.courseId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openCourseDetail(context, course.courseId),
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A2A3B)
                          : const Color(0xFFF8FBFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                      boxShadow: isDark
                          ? null
                          : const [
                              BoxShadow(
                                color: Color(0x0D0B1A33),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Container(
                            width: 144,
                            height: 108,
                            color: isDark
                                ? const Color(0xFF243548)
                                : const Color(0xFFE5E7EB),
                            child: photoUrl == null
                                ? Icon(
                                    Icons.image_not_supported_outlined,
                                    color: muted,
                                    size: 26,
                                  )
                                : Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Icon(
                                        Icons.image_not_supported_outlined,
                                        color: muted,
                                        size: 26,
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.courseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: (course.progressPercent / 100).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    minHeight: 8,
                                    backgroundColor: isDark
                                        ? const Color(0xFF2D4258)
                                        : const Color(0xFFE5EAF3),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF2F6BFF),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${course.completedActivities}/${course.totalActivities} '
                                  '${tr(context, uz: 'aktiv', ru: 'активностей')} • '
                                  '${course.progressPercent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DashboardErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(tr(context, uz: 'Qayta urinish', ru: 'Повторить')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainDashboardData {
  final String fullName;
  final DashboardSummary summary;
  final List<DashboardCurrentCourse> currentCourses;
  final DashboardProgress? progress;
  final DashboardTimeStats? timeStats;
  final Map<int, String> coursePhotoById;

  const _MainDashboardData({
    required this.fullName,
    required this.summary,
    required this.currentCourses,
    required this.progress,
    required this.timeStats,
    required this.coursePhotoById,
  });
}

class _BarPoint {
  final String label;
  final int value;

  const _BarPoint({required this.label, required this.value});
}

double _calcOverallProgress(List<DashboardCurrentCourse> courses) {
  if (courses.isEmpty) return 0;
  final sum = courses.fold<double>(0, (acc, c) => acc + c.progressPercent);
  return sum / courses.length;
}

String _weekday2(BuildContext context, int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return tr(context, uz: 'Du', ru: 'Пн');
    case DateTime.tuesday:
      return tr(context, uz: 'Se', ru: 'Вт');
    case DateTime.wednesday:
      return tr(context, uz: 'Ch', ru: 'Ср');
    case DateTime.thursday:
      return tr(context, uz: 'Pa', ru: 'Чт');
    case DateTime.friday:
      return tr(context, uz: 'Ju', ru: 'Пт');
    case DateTime.saturday:
      return tr(context, uz: 'Sh', ru: 'Сб');
    case DateTime.sunday:
      return tr(context, uz: 'Ya', ru: 'Вс');
  }
  return '--';
}
