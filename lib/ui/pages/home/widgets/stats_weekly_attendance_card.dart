import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class StatsWeeklyAttendanceCard extends StatelessWidget {
  const StatsWeeklyAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.statsCardDark : AppColors.white;
    final border = isDark
        ? AppColors.homeCardBorderDark
        : AppColors.homeCardBorderLight;
    final titleColor = isDark ? AppColors.white : AppColors.lightText;
    final muted = isDark ? AppColors.courseMutedDark : AppColors.lightMuted;
    final chipBg = isDark ? AppColors.statsChipDark : AppColors.lightBackground;
    final chipText = isDark ? AppColors.darkText : AppColors.lightMuted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr(context, TrKey.haftalikQatnashish),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: chipText, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr(context, TrKey.t18Noyabr2025),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: chipText, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: chipText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(context, TrKey.t44Hafta),
            style: TextStyle(color: muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 6.0;
              final availableWidth = constraints.maxWidth;
              final rawWidth = (availableWidth - gap * 6) / 7;
              final chipWidth = rawWidth > 0 ? rawWidth : 0.0;
              return Row(
                children: [
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.du),
                    day: '29',
                    selected: true,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.se),
                    day: '30',
                    selected: true,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.ch),
                    day: '31',
                    selected: false,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.pa),
                    day: '1',
                    selected: true,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.ju),
                    day: '2',
                    selected: false,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.sh),
                    day: '3',
                    selected: false,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, TrKey.ya),
                    day: '4',
                    selected: false,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final String day;
  final bool selected;
  final double width;

  const _DayChip({
    required this.label,
    required this.day,
    required this.selected,
    this.width = 42,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? scheme.primary.withValues(alpha: isDark ? 0.7 : 0.2)
        : (isDark ? AppColors.statsDayBgDark : AppColors.lightBackground);
    final border = isDark
        ? AppColors.statsDayBorderDark
        : AppColors.lightBorder;
    final labelColor = isDark
        ? AppColors.courseMutedDark
        : AppColors.lightMuted;
    final dayColor = isDark ? AppColors.white : AppColors.lightText;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(color: dayColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
