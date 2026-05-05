import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class CourseLearningPoint extends StatelessWidget {
  const CourseLearningPoint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.courseLearningSuccess,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
