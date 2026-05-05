import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/schedule_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class ScheduleDayLessonItem {
  final ScheduleRow row;
  final LessonInfo lesson;

  const ScheduleDayLessonItem({required this.row, required this.lesson});

  String get startTimeLabel {
    final raw = row.time.trim();
    if (raw.isEmpty) return '--:--';
    final parts = raw.split(RegExp(r'\s*-\s*'));
    return parts.first;
  }
}

class ScheduleTimelineLessonTile extends StatelessWidget {
  final ScheduleDayLessonItem item;
  final bool isFirst;
  final bool isLast;
  final void Function(String meetingId) onJoinMeeting;

  const ScheduleTimelineLessonTile({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.onJoinMeeting,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeColor = isDark
        ? const Color(0xFFA5B3C2)
        : const Color(0xFF7A808A);
    final lineColor = isDark
        ? const Color(0xFF36516B)
        : const Color(0xFFC7D3E0);
    final dotBorder = isDark
        ? const Color(0xFF2D3F53)
        : const Color(0xFFD5DEE8);
    const dotFill = Color(0xFF1292EE);
    final cardBg = isDark ? AppColors.homeInnerCardDark : AppColors.white;
    final titleColor = isDark ? AppColors.white : AppColors.lightText;
    final subColor = isDark ? const Color(0xFFC4D0DD) : const Color(0xFF4B5563);
    final metaColor = isDark ? const Color(0xFF9BB0C4) : AppColors.mutedGray;
    final border = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;
    final onlineColor = isDark
        ? const Color(0xFF77C2FF)
        : const Color(0xFF0E7BD5);
    final meetingId = item.lesson.bbbObject.meetingId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 74,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  item.startTimeLabel,
                  style: TextStyle(
                    color: timeColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 24,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 1.5,
                        color: isFirst && isLast
                            ? AppColors.transparent
                            : lineColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: dotFill,
                        shape: BoxShape.circle,
                        border: Border.all(color: dotBorder, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.lesson.theme?.trim().isNotEmpty == true
                                ? item.lesson.theme!
                                : tr(context, TrKey.dars),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (meetingId != null && meetingId.isNotEmpty)
                          InkWell(
                            onTap: () => onJoinMeeting(meetingId),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Icon(
                                Icons.video_call_rounded,
                                color: onlineColor,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if ((item.lesson.group ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.lesson.group!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: metaColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.row.time,
                          style: TextStyle(
                            color: metaColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if ((item.lesson.educationType ?? '').isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: metaColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.lesson.educationType!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: metaColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
