import 'package:flutter/material.dart';
import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/courses/course_info_initial_data_mapper.dart';
import 'package:uztelecom/ui/widgets/authorized_network_image.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.item});

  final CourseItem item;

  String? _absoluteUrl(String? path) {
    return AppConfig.absoluteUrl(path);
  }

  String? _durationLabel(BuildContext context) {
    if (item.hours != null) {
      return tr(context, TrKey.soat, params: {'p1': item.hours});
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
    final localeCode = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.courseCardDark : AppColors.white;
    final border = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;
    final thumbBg = isDark
        ? AppColors.courseThumbDark
        : AppColors.courseThumbLight;
    final titleColor = isDark ? AppColors.white : AppColors.courseTitleLight;
    final muted = isDark
        ? AppColors.courseMutedDark
        : AppColors.courseMutedLight;
    final actionColor = isDark
        ? AppColors.courseActionDark
        : AppColors.brandBlue;
    final photoUrl = _absoluteUrl(item.photo);
    final audience = item.audienceFor(localeCode)?.trim();
    final trainerName = item.trainerName?.trim();
    final durationLabel = _durationLabel(context);
    return InkWell(
      onTap: () {
        AppNavigator.pushCourseInfo(
          context,
          courseId: item.id,
          initialData: courseInfoInitialDataFromCourseItem(item),
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
                    color: AppColors.authCardShadow,
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
                          : AuthorizedNetworkImage(
                              url: photoUrl,
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
                            AppColors.courseOverlayMid,
                            AppColors.courseOverlayEnd,
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
                            color: AppColors.courseAudienceBadge,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            audience,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
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
                    item.titleFor(localeCode) ??
                        item.courseNameFor(localeCode) ??
                        tr(context, TrKey.kurs),
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
                        tr(context, TrKey.kursniKorish),
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
