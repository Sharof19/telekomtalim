import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_palette.dart';

class ExamResultSummaryCard extends StatelessWidget {
  const ExamResultSummaryCard({
    super.key,
    required this.attemptNumber,
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.wrongCount,
  });

  final int attemptNumber;
  final int score;
  final int maxScore;
  final int correctCount;
  final int wrongCount;

  @override
  Widget build(BuildContext context) {
    final palette = ExamPalette.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, TrKey.urinish, params: {'p1': attemptNumber}),
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _ExamScoreChip(
                text: tr(
                  context,
                  TrKey.ball2,
                  params: {'p1': score, 'p2': maxScore},
                ),
                color: palette.scoreBlue,
              ),
              _ExamScoreChip(
                text: tr(context, TrKey.togri, params: {'p1': correctCount}),
                color: palette.scoreGreen,
              ),
              _ExamScoreChip(
                text: tr(context, TrKey.xato, params: {'p1': wrongCount}),
                color: palette.scoreRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamScoreChip extends StatelessWidget {
  const _ExamScoreChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
