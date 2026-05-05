import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

void showProfileInfoSavedBanner(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentMaterialBanner();
  messenger.showMaterialBanner(
    MaterialBanner(
      elevation: 0,
      backgroundColor: AppColors.profileBannerBg,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, TrKey.malumotlarSaqlandi),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.profileBannerTitle,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr(context, TrKey.malumotlaringizMuvaffaqiyatliSaqlandi),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.profileBannerText,
            ),
          ),
        ],
      ),
      leading: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.profileBannerIconBg,
        child: Icon(Icons.verified_rounded, color: AppColors.profileBannerIcon),
      ),
      actions: [
        IconButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          icon: const Icon(Icons.close, color: AppColors.profileBannerClose),
        ),
      ],
    ),
  );
}
