import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_session_card.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_session_timer_badge.dart';

class ExamSessionHeaderCard extends StatelessWidget {
  const ExamSessionHeaderCard({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.attemptNumber,
    required this.examAttemptId,
    required this.answered,
    required this.total,
    required this.remainingSeconds,
  });

  final Color backgroundColor;
  final Color borderColor;
  final int? attemptNumber;
  final int? examAttemptId;
  final int answered;
  final int total;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = examAttemptId != null ? '#$examAttemptId' : '';
    return ExamSessionCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, TrKey.imtihon, params: {'p1': label}),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr(
                    context,
                    TrKey.urinish2,
                    params: {'p1': attemptNumber ?? 1},
                  ),
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tr(context, TrKey.javobBerilgan),
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              Text(
                '$answered / $total',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ExamSessionTimerBadge(seconds: remainingSeconds),
            ],
          ),
        ],
      ),
    );
  }
}
