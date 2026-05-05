import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class ScheduleDayEmptyState extends StatelessWidget {
  final String message;

  const ScheduleDayEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF96A8BB) : AppColors.mutedGray;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ScheduleEmptyState extends StatelessWidget {
  final String message;

  const ScheduleEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 15),
      ),
    );
  }
}
