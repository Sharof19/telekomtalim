import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_palette.dart';

class ProfileInfoFieldSection extends StatelessWidget {
  final String label;
  final Widget child;
  final String? counterText;
  final TextStyle labelStyle;
  final TextStyle counterStyle;

  const ProfileInfoFieldSection({
    super.key,
    required this.label,
    required this.child,
    this.counterText,
    required this.labelStyle,
    required this.counterStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 10),
        child,
        if (counterText != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(counterText!, style: counterStyle),
          ),
        ],
      ],
    );
  }
}

class ProfileInfoErrorCard extends StatelessWidget {
  final String message;
  final ProfileInfoPalette palette;
  final double fontSize;

  const ProfileInfoErrorCard({
    super.key,
    required this.message,
    required this.palette,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.input,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: palette.value,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProfileInfoPrimaryButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final String label;
  final Color backgroundColor;

  const ProfileInfoPrimaryButton({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}
