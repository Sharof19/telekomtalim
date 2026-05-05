import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/courses/course_use_cases.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_empty_state.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_info_details_section.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_info_media_section.dart';

class CourseInfoPage extends StatefulWidget {
  const CourseInfoPage({
    super.key,
    required this.courseId,
    this.initialItem,
    this.useMyCoursesDetailApi = false,
  });

  final int courseId;
  final CourseInfoInitialData? initialItem;
  final bool useMyCoursesDetailApi;

  @override
  State<CourseInfoPage> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> {
  late final LoadCourseDetailUseCase _loadCourseDetail;
  late final ResolveCourseResourcesUseCase _resolveResources;

  late final Future<CourseItem> _detailFuture;

  bool _requestSubmitted = false;

  CourseItem? get _initialCourseItem {
    final item = widget.initialItem;
    if (item == null) return null;
    return CourseItem(
      id: item.id,
      status: item.status,
      photo: item.photo,
      mainVideo: item.mainVideo,
      file: item.file,
      filePath: item.filePath,
      launchUrl: item.launchUrl,
      fullQuery: item.fullQuery,
      duration: item.duration,
      hours: item.hours,
      days: item.days,
      trainerName: item.trainerName,
      listenerCount: item.listenerCount,
      titleUz: item.titleUz,
      titleRu: item.titleRu,
      descriptionUz: item.descriptionUz,
      descriptionRu: item.descriptionRu,
      courseNameUz: item.courseNameUz,
      courseNameRu: item.courseNameRu,
      languageUz: item.languageUz,
      languageRu: item.languageRu,
      audienceUz: item.audienceUz,
      audienceRu: item.audienceRu,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCourseDetail = context.read<LoadCourseDetailUseCase>();
    _resolveResources = context.read<ResolveCourseResourcesUseCase>();
    _detailFuture = _loadCourseDetail(
      courseId: widget.courseId,
      useMyCoursesDetailApi: widget.useMyCoursesDetailApi,
    );
  }

  Future<void> _openWebviewResource(String url, CourseItem item) async {
    final safeUrl = _resolveResources.normalizeLaunchUrl(url);
    final uri = Uri.tryParse(safeUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.resursHavolasiNotogri))),
      );
      return;
    }
    final localeCode = Localizations.localeOf(context).languageCode;
    await AppNavigator.pushContentWebview<void>(
      context,
      url: safeUrl,
      title: item.titleFor(localeCode) ?? tr(context, TrKey.kurs),
      fallbackVideoUrl: item.mainVideo,
    );
  }

  Future<void> _openCourseResource(CourseItem displayedItem) async {
    final resources = _resolveResources(
      item: displayedItem,
      fallback: _initialCourseItem,
    );
    final contentUrl = resources.contentUrl;
    if (contentUrl == null || contentUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.resursHavolasiTopilmadi))),
      );
      return;
    }

    await _openWebviewResource(contentUrl, displayedItem);
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = isDark ? AppColors.white : AppColors.lightText;
    final textMuted = isDark
        ? AppColors.courseMutedDark
        : AppColors.courseMutedLight;
    final infoCardBg = isDark ? const Color(0xFF2A4D6E) : AppColors.white;
    final infoCardBorder = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;
    final infoDivider = infoCardBorder;
    final infoTitleColor = isDark ? AppColors.white : AppColors.lightText;
    final resourceButtonForeground = isDark
        ? AppColors.white
        : AppColors.brandBlue;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        foregroundColor: scheme.onSurface,
        title: Text(
          tr(context, TrKey.kursMalumotlari),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<CourseItem>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final item = snapshot.data ?? _initialCourseItem;
          if (item == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: scheme.primary),
              );
            }
            return CourseEmptyState(
              message: tr(context, TrKey.kursMalumotlariniYuklashdaXatolik),
            );
          }

          final resources = _resolveResources(
            item: item,
            fallback: _initialCourseItem,
          );
          final photoUrl = resources.photoUrl;
          final videoUrl = resources.videoUrl;
          final contentUrl = resources.contentUrl;
          final hasMedia = videoUrl != null || photoUrl != null;

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
                if (hasMedia) ...[
                  CourseInfoMediaSection(
                    videoUrl: videoUrl,
                    photoUrl: photoUrl,
                    loaderColor: scheme.primary,
                  ),
                  const SizedBox(height: 12),
                ],
                CourseInfoDetailsSection(
                  item: item,
                  localeCode: localeCode,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  infoCardBg: infoCardBg,
                  infoCardBorder: infoCardBorder,
                  infoDivider: infoDivider,
                  infoTitleColor: infoTitleColor,
                  resourceButtonForeground: resourceButtonForeground,
                  contentUrl: contentUrl,
                  useMyCoursesDetailApi: widget.useMyCoursesDetailApi,
                  requestSubmitted: _requestSubmitted,
                  onOpenResource: () => _openCourseResource(item),
                  onRequestSubmitted: () {
                    setState(() {
                      _requestSubmitted = true;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
