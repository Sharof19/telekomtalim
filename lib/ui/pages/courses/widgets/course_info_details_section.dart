import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_info_overview_card.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_info_request_button.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_meta_chip.dart';

class CourseInfoDetailsSection extends StatelessWidget {
  const CourseInfoDetailsSection({
    super.key,
    required this.item,
    required this.localeCode,
    required this.textPrimary,
    required this.textMuted,
    required this.infoCardBg,
    required this.infoCardBorder,
    required this.infoDivider,
    required this.infoTitleColor,
    required this.resourceButtonForeground,
    required this.contentUrl,
    required this.useMyCoursesDetailApi,
    required this.requestSubmitted,
    required this.onOpenResource,
    required this.onRequestSubmitted,
  });

  final CourseItem item;
  final String localeCode;
  final Color textPrimary;
  final Color textMuted;
  final Color infoCardBg;
  final Color infoCardBorder;
  final Color infoDivider;
  final Color infoTitleColor;
  final Color resourceButtonForeground;
  final String? contentUrl;
  final bool useMyCoursesDetailApi;
  final bool requestSubmitted;
  final Future<void> Function() onOpenResource;
  final VoidCallback onRequestSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.titleFor(localeCode) ??
              item.courseNameFor(localeCode) ??
              tr(context, TrKey.kurs),
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if ((item.descriptionFor(localeCode) ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.descriptionFor(localeCode)!,
            style: TextStyle(color: textMuted, fontSize: 13, height: 1.4),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (item.hours != null) CourseMetaChip(text: '${item.hours} soat'),
            if (item.days != null) CourseMetaChip(text: '${item.days} kun'),
            if ((item.status ?? '').isNotEmpty)
              CourseMetaChip(text: item.status!),
            if ((item.duration ?? '').isNotEmpty)
              CourseMetaChip(text: 'Sana: ${item.duration}'),
          ],
        ),
        const SizedBox(height: 20),
        CourseInfoOverviewCard(
          backgroundColor: infoCardBg,
          borderColor: infoCardBorder,
          dividerColor: infoDivider,
          titleColor: infoTitleColor,
        ),
        if (contentUrl != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenResource,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Resurslar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: resourceButtonForeground,
                    side: const BorderSide(
                      color: AppColors.courseResourceBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (!useMyCoursesDetailApi) ...[
          const SizedBox(height: 14),
          CourseInfoRequestButton(
            requestSubmitted: requestSubmitted,
            onPressed: onRequestSubmitted,
          ),
        ],
      ],
    );
  }
}
