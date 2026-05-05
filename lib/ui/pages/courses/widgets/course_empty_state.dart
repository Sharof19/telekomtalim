import 'package:flutter/material.dart';

class CourseEmptyState extends StatelessWidget {
  const CourseEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: 15),
      ),
    );
  }
}
