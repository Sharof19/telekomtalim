import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/widgets/authorized_network_image.dart';

class DashboardCurrentCoursesCard extends StatelessWidget {
  const DashboardCurrentCoursesCard({
    super.key,
    required this.courses,
    required this.photoByCourseId,
    required this.progressCache,
  });

  final List<DashboardCurrentCourse> courses;
  final Map<int, String> photoByCourseId;
  final Map<int, double> progressCache;

  void _openCourseDetail(BuildContext context, int courseId) {
    if (courseId <= 0) return;
    AppNavigator.pushCourseInfo(
      context,
      courseId: courseId,
      useMyCoursesDetailApi: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark
        ? AppColors.homeCardBorderDark
        : AppColors.homeCardBorderLight;
    final titleColor = isDark ? AppColors.white : AppColors.lightText;
    final muted = isDark ? AppColors.mutedBlueGray : AppColors.mutedGray;

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
                  color: AppColors.overlayShadow,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, TrKey.joriyKurslar),
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (courses.isEmpty)
            Text(
              tr(context, TrKey.hozirchaJoriyKursYoq),
              style: TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ...courses.take(3).map((course) {
            final photoUrl = photoByCourseId[course.courseId];
            final currentPercent = course.progressPercent;
            final previousPercent =
                progressCache[course.courseId] ?? currentPercent;
            final begin = currentPercent > previousPercent
                ? previousPercent
                : currentPercent;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openCourseDetail(context, course.courseId),
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.homeInnerCardDark
                          : AppColors.homeInnerCardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                      boxShadow: isDark
                          ? null
                          : const [
                              BoxShadow(
                                color: AppColors.overlayShadowSoft,
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
                                ? AppColors.homeCardBorderDark
                                : AppColors.homeCardBorderLight,
                            child: photoUrl == null
                                ? Icon(
                                    Icons.image_not_supported_outlined,
                                    color: muted,
                                    size: 26,
                                  )
                                : AuthorizedNetworkImage(
                                    url: photoUrl,
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
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: begin,
                                    end: currentPercent,
                                  ),
                                  duration: currentPercent > previousPercent
                                      ? const Duration(milliseconds: 650)
                                      : Duration.zero,
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) {
                                    final clamped = (value / 100).clamp(
                                      0.0,
                                      1.0,
                                    );
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: clamped,
                                            minHeight: 8,
                                            backgroundColor: isDark
                                                ? AppColors
                                                      .courseProgressTrackDark
                                                : AppColors
                                                      .courseProgressTrackLight,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(AppColors.brandBlue),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${course.completedActivities}/${course.totalActivities} '
                                          '${tr(context, TrKey.aktiv)} • '
                                          '${value.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
