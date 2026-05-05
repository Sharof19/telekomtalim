import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class DashboardWelcomeCard extends StatelessWidget {
  const DashboardWelcomeCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.white
        : AppColors.homeTitleStrongLight;
    final textMuted = isDark
        ? AppColors.darkMuted
        : AppColors.homeSubtitleLight;

    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.primary
              : AppColors.brandBlue,
          child: Text(
            name.isNotEmpty ? name.characters.first.toUpperCase() : 'U',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tr(context, TrKey.xushKelibsiz),
                style: TextStyle(
                  color: textMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
