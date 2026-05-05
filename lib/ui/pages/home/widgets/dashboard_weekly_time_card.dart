import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class DashboardWeeklyTimeCard extends StatelessWidget {
  const DashboardWeeklyTimeCard({super.key, required this.days});

  final List<DashboardDayStat> days;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark
        ? AppColors.homeCardBorderDark
        : AppColors.homeCardBorderLight;
    final titleColor = isDark ? AppColors.white : AppColors.lightText;
    final muted = isDark ? AppColors.homeMutedDarkAlt : AppColors.mutedGray;

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
                  color: AppColors.overlayShadow,
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
                  tr(context, TrKey.haftalikFaollik),
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

class _BarPoint {
  const _BarPoint({required this.label, required this.value});

  final String label;
  final int value;
}

String _weekday2(BuildContext context, int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return tr(context, TrKey.du);
    case DateTime.tuesday:
      return tr(context, TrKey.se);
    case DateTime.wednesday:
      return tr(context, TrKey.ch);
    case DateTime.thursday:
      return tr(context, TrKey.pa);
    case DateTime.friday:
      return tr(context, TrKey.ju);
    case DateTime.saturday:
      return tr(context, TrKey.sh);
    case DateTime.sunday:
      return tr(context, TrKey.ya);
  }
  return '--';
}
