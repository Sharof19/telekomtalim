import 'package:flutter/material.dart';

class ExamSessionCard extends StatelessWidget {
  const ExamSessionCard({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
