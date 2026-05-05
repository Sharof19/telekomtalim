import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class DashboardMiniStatCard extends StatelessWidget {
  const DashboardMiniStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark
        ? AppColors.homeCardBorderDark
        : AppColors.homeCardBorderLight;
    final titleColor = isDark
        ? AppColors.mutedBlueGray
        : AppColors.homeMutedLightAlt;
    final valueColor = isDark ? AppColors.white : AppColors.homeValueLight;
    final iconBg = isDark
        ? iconColor.withValues(alpha: 0.22)
        : iconColor.withValues(alpha: 0.14);

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 118,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
