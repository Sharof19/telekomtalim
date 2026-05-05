import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class StatsWeeklyViewCard extends StatelessWidget {
  const StatsWeeklyViewCard({super.key});

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
                  tr(context, TrKey.haftalikKorish),
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
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Bar(label: '8', value: 0.45),
              _Bar(label: '6', value: 0.35),
              _Bar(label: '7', value: 0.6, highlighted: true),
              _Bar(label: '4', value: 0.28),
              _Bar(label: '5', value: 0.42),
              _Bar(label: '3', value: 0.22),
              _Bar(label: '6', value: 0.35),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final bool highlighted;

  const _Bar({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = highlighted
        ? scheme.primary
        : (isDark ? AppColors.statsBarDark : AppColors.lightBorder);
    final labelColor = isDark
        ? AppColors.courseMutedDark
        : AppColors.lightMuted;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 90 * value,
            width: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(context, TrKey.soat, params: {'p1': label}),
            style: TextStyle(color: labelColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
