import 'package:flutter/material.dart';
import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_palette.dart';

class ExamResultQuestionCard extends StatelessWidget {
  const ExamResultQuestionCard({
    super.key,
    required this.index,
    required this.question,
  });

  final int index;
  final ExamResultQuestion question;

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
            tr(context, TrKey.savol, params: {'p1': index}),
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.text,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...question.answers.asMap().entries.map((entry) {
            final answer = entry.value;
            final label = String.fromCharCode(65 + entry.key);
            final isCorrect = answer.isTrue;
            final isSelected = answer.isSelected;

            var background = palette.answerBackground;
            var border = palette.answerBorder;
            var textColor = palette.answerText;
            IconData? trailing;
            var trailingColor = palette.answerTrailing;

            if (isSelected && isCorrect) {
              background = palette.answerCorrectBackground;
              border = palette.scoreGreen;
              textColor = palette.answerCorrectText;
              trailing = Icons.check_circle;
              trailingColor = palette.scoreGreen;
            } else if (isSelected && !isCorrect) {
              background = palette.answerWrongBackground;
              border = palette.scoreRed;
              textColor = palette.answerWrongText;
              trailing = Icons.cancel;
              trailingColor = palette.scoreRed;
            } else if (!isSelected && isCorrect) {
              background = palette.answerExpectedBackground;
              border = palette.scoreBlue;
              textColor = palette.answerExpectedText;
              trailing = Icons.check_circle_outline;
              trailingColor = palette.scoreBlue;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: palette.primaryActionForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        answer.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailing, size: 18, color: trailingColor),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
