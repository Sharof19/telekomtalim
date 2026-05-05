import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class CourseFeatureCard extends StatelessWidget {
  const CourseFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.courseFeatureBgDark
        : AppColors.courseFeatureBgLight;
    final border = isDark
        ? AppColors.courseFeatureBorderDark
        : Theme.of(context).dividerColor;
    final titleColor = isDark
        ? AppColors.white
        : Theme.of(context).colorScheme.onSurface;
    final subtitleColor = isDark
        ? const Color(0xFFB9C9DB)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Container(
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.white, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: subtitleColor, fontSize: 9),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
