import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class StatsProgressCard extends StatelessWidget {
  const StatsProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final cardBg = isDark ? AppColors.statsProgressCardDark : AppColors.white;
    final border = isDark
        ? AppColors.homeCardBorderDark
        : AppColors.homeCardBorderLight;
    final textPrimary = isDark ? AppColors.white : AppColors.lightText;
    final textMuted = isDark ? AppColors.courseMutedDark : AppColors.lightMuted;
    final ringBg = isDark
        ? AppColors.statsRingDark
        : AppColors.courseProgressTrackLight;
    final ringFg = isDark ? AppColors.statsRingSuccess : scheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: AppColors.shadowStrong,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    color: ringBg,
                  ),
                ),
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 10,
                    color: ringFg,
                  ),
                ),
                Text(
                  '70%',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, color: textMuted, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      tr(context, TrKey.organishJarayoni),
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tr(context, TrKey.tugatilganKurslar),
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '7/10',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
