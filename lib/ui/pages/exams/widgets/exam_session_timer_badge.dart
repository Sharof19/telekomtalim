import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class ExamSessionTimerBadge extends StatelessWidget {
  const ExamSessionTimerBadge({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.examSessionTimerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            '$minutes:$secs',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
