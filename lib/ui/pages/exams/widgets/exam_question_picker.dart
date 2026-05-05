import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_session_card.dart';

class ExamQuestionPicker extends StatelessWidget {
  const ExamQuestionPicker({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.currentIndex,
    required this.total,
    required this.onSelect,
  });

  final Color backgroundColor;
  final Color borderColor;
  final int currentIndex;
  final int total;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ExamSessionCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, TrKey.savollarRoyxati),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(total, (index) {
              final selected = index == currentIndex;
              return InkWell(
                onTap: () => onSelect(index),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.brandBlue
                        : AppColors.examAnswerIdleBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
