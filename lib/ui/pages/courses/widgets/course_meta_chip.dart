import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class CourseMetaChip extends StatelessWidget {
  const CourseMetaChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final bg = isDark
        ? AppColors.accentBlueDeep
        : scheme.secondary.withValues(alpha: 0.12);
    final textColor = isDark ? AppColors.white : scheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
