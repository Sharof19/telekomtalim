import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_palette.dart';

class ExamErrorState extends StatelessWidget {
  const ExamErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final examColors = ExamPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: examColors.mutedText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(tr(context, TrKey.retryAction)),
            ),
          ],
        ),
      ),
    );
  }
}
