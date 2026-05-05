import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class CourseInfoRequestButton extends StatelessWidget {
  const CourseInfoRequestButton({
    super.key,
    required this.requestSubmitted,
    required this.onPressed,
  });

  final bool requestSubmitted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: requestSubmitted
              ? const LinearGradient(
                  colors: [
                    AppColors.courseRequestSubmittedStart,
                    AppColors.courseRequestSubmittedEnd,
                  ],
                )
              : const LinearGradient(
                  colors: [AppColors.accentBlueDeep, AppColors.accentBlueDeep],
                ),
        ),
        child: ElevatedButton(
          onPressed: requestSubmitted ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.transparent,
            shadowColor: AppColors.transparent,
            foregroundColor: AppColors.white,
            disabledForegroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            requestSubmitted ? 'Murojaat qoldirildi' : 'Murojaat qoldirish',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
