import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class ScheduleWeekHeader extends StatelessWidget {
  final String dayHeader;
  final String dateHeader;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final bool showCopyTokenAction;
  final VoidCallback? onCopyToken;

  const ScheduleWeekHeader({
    super.key,
    required this.dayHeader,
    required this.dateHeader,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.showCopyTokenAction,
    this.onCopyToken,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.white : AppColors.lightText;
    final dateColor = isDark ? const Color(0xFF9AA6B2) : AppColors.mutedGray;

    return Row(
      children: [
        const SizedBox(width: 6),
        IconButton(
          onPressed: onPreviousWeek,
          icon: Icon(Icons.chevron_left_rounded, color: titleColor, size: 28),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                dayHeader,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateHeader,
                style: TextStyle(
                  color: dateColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNextWeek,
          icon: Icon(Icons.chevron_right_rounded, color: titleColor, size: 28),
        ),
        if (showCopyTokenAction)
          IconButton(
            onPressed: onCopyToken,
            icon: Icon(Icons.copy_rounded, color: dateColor, size: 20),
            tooltip: tr(context, TrKey.tokenniNusxalash),
          ),
        const SizedBox(width: 6),
      ],
    );
  }
}
