import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_palette.dart';

class ExamEmptyListState extends StatelessWidget {
  const ExamEmptyListState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedText = ExamPalette.of(context).mutedText;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFDCEBFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF4A90E2),
              size: 52,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            tr(context, TrKey.imtihonlarTopilmadi),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            tr(context, TrKey.hozirchaSizgaTayinlanganImtihonlarYoq),
            style: TextStyle(
              fontSize: 18,
              color: mutedText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
