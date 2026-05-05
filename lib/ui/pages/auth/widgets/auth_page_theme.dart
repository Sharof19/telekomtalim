import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

abstract final class AuthPageTheme {
  static ThemeData light() {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandBlue,
        secondary: AppColors.brandBlue,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.authOnSurface,
      ),
      iconTheme: const IconThemeData(color: AppColors.brandBlue),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brandBlue,
        selectionColor: AppColors.authSelection,
        selectionHandleColor: AppColors.brandBlue,
      ),
    );
  }

  static BorderSide get inputBorderSide =>
      const BorderSide(color: AppColors.authBorder);

  static OutlineInputBorder inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: inputBorderSide,
    );
  }

  static OutlineInputBorder focusedInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.4),
    );
  }

  static InputDecoration inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8BA0C2)),
      floatingLabelStyle: const TextStyle(
        color: AppColors.brandBlue,
        fontWeight: FontWeight.w600,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC0CBE0), fontSize: 16),
      prefixIcon: icon == null && prefixText == null
          ? null
          : _AuthInputPrefix(icon: icon, text: prefixText),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: inputBorder(),
      enabledBorder: inputBorder(),
      focusedBorder: focusedInputBorder(AppColors.brandBlue),
      errorBorder: inputBorder(),
      focusedErrorBorder: focusedInputBorder(AppColors.brandBlue),
      prefixIconColor: AppColors.brandBlue,
      suffixIconColor: AppColors.brandBlue,
      iconColor: AppColors.brandBlue,
    );
  }
}

class _AuthInputPrefix extends StatelessWidget {
  const _AuthInputPrefix({this.icon, this.text});

  final IconData? icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: AppColors.brandBlue, size: 22),
          if (icon != null && text != null) const SizedBox(width: 14),
          if (text != null)
            Text(
              text!,
              style: const TextStyle(
                color: AppColors.authOnSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
