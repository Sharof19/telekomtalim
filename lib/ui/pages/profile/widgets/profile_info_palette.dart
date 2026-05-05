import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class ProfileInfoPalette {
  final Color background;
  final Color title;
  final Color input;
  final Color value;
  final Color border;
  final Color borderFocused;
  final Color counter;
  final Color button;

  const ProfileInfoPalette._({
    required this.background,
    required this.title,
    required this.input,
    required this.value,
    required this.border,
    required this.borderFocused,
    required this.counter,
    required this.button,
  });

  factory ProfileInfoPalette.resolve(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ProfileInfoPalette._(
      background: isDark
          ? AppColors.profileInfoBackgroundDark
          : AppColors.profileBackgroundLightAlt,
      title: isDark
          ? AppColors.profileInfoTitleDark
          : AppColors.profileInfoTitleLight,
      input: isDark ? AppColors.profileInfoInputDark : AppColors.white,
      value: isDark
          ? AppColors.profileInfoValueDark
          : AppColors.profileInfoValueLight,
      border: isDark
          ? AppColors.profileInfoInputDark
          : AppColors.profileInfoBorderLight,
      borderFocused: isDark
          ? AppColors.brandBlue
          : AppColors.profileInfoFocusedLight,
      counter: isDark
          ? AppColors.profileInfoCounterDark
          : AppColors.profileInfoCounterLight,
      button: AppColors.brandBlue,
    );
  }
}
