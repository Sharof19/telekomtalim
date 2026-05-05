import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/app_route_args.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_session_card.dart';

class ExamQuestionCard extends StatelessWidget {
  const ExamQuestionCard({
    super.key,
    required this.question,
    required this.backgroundColor,
    required this.borderColor,
    required this.selectedAnswerId,
    required this.isSaving,
    required this.onSelect,
  });

  final ExamQuestionData question;
  final Color backgroundColor;
  final Color borderColor;
  final int? selectedAnswerId;
  final bool isSaving;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExamSessionCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr(context, TrKey.savol2),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkMuted
                      : AppColors.lightMuted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (selectedAnswerId != null)
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.courseFeatureCertificate,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tr(context, TrKey.javobBerildi),
                      style: const TextStyle(
                        color: AppColors.courseFeatureCertificate,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              if (isSaving) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: question.answers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final answer = question.answers[index];
                final selected = selectedAnswerId == answer.id;
                return InkWell(
                  onTap: () => onSelect(answer.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.examAnswerSelectedBg
                          : AppColors.examAnswerIdleBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.brandBlue
                            : AppColors.examAnswerIdleBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.brandBlue
                                : AppColors.examAnswerIdleBadge,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            answer.text,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.brandBlue,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
