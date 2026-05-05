import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class ExamEmptyCard extends StatelessWidget {
  const ExamEmptyCard({super.key, required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedText = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = Theme.of(context).dividerColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isError ? AppColors.error : mutedText,
        ),
      ),
    );
  }
}
