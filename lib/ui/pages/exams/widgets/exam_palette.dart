import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class ExamPalette {
  const ExamPalette({
    required this.mutedText,
    required this.scoreBlue,
    required this.scoreGreen,
    required this.scoreRed,
    required this.chipFinishedBackground,
    required this.chipInProgressBackground,
    required this.chipInProgressText,
    required this.answerBackground,
    required this.answerBorder,
    required this.answerText,
    required this.answerTrailing,
    required this.answerCorrectBackground,
    required this.answerCorrectText,
    required this.answerWrongBackground,
    required this.answerWrongText,
    required this.answerExpectedBackground,
    required this.answerExpectedText,
    required this.primaryActionForeground,
  });

  final Color mutedText;
  final Color scoreBlue;
  final Color scoreGreen;
  final Color scoreRed;
  final Color chipFinishedBackground;
  final Color chipInProgressBackground;
  final Color chipInProgressText;
  final Color answerBackground;
  final Color answerBorder;
  final Color answerText;
  final Color answerTrailing;
  final Color answerCorrectBackground;
  final Color answerCorrectText;
  final Color answerWrongBackground;
  final Color answerWrongText;
  final Color answerExpectedBackground;
  final Color answerExpectedText;
  final Color primaryActionForeground;

  static ExamPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExamPalette(
      mutedText: isDark ? AppColors.darkMuted : AppColors.lightMuted,
      scoreBlue: AppColors.brandBlue,
      scoreGreen: AppColors.examScoreGreen,
      scoreRed: const Color(0xFFDC2626),
      chipFinishedBackground: const Color(0x1A22C55E),
      chipInProgressBackground: const Color(0x1AF59E0B),
      chipInProgressText: const Color(0xFFB45309),
      answerBackground: const Color(0xFFF3F4F6),
      answerBorder: AppColors.borderGrayLight,
      answerText: AppColors.lightText,
      answerTrailing: AppColors.mutedGray,
      answerCorrectBackground: const Color(0xFFE8F9EF),
      answerCorrectText: const Color(0xFF166534),
      answerWrongBackground: const Color(0xFFFEECEC),
      answerWrongText: const Color(0xFF991B1B),
      answerExpectedBackground: const Color(0xFFEAF2FF),
      answerExpectedText: AppColors.examAnswerExpectedText,
      primaryActionForeground: AppColors.white,
    );
  }
}
