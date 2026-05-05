import 'package:flutter/material.dart';
import 'package:uztelecom/data/models/exam_models.dart';

class ExamAttemptCard extends StatelessWidget {
  const ExamAttemptCard({
    super.key,
    required this.item,
    required this.statusText,
    required this.startText,
    required this.endText,
    required this.mutedText,
    required this.scoreGreen,
    required this.chipInProgressBackground,
    required this.chipInProgressText,
    required this.onViewResult,
  });

  final ExamAttemptItem item;
  final String statusText;
  final String startText;
  final String endText;
  final Color mutedText;
  final Color scoreGreen;
  final Color chipInProgressBackground;
  final Color chipInProgressText;
  final VoidCallback? onViewResult;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finished = item.status.toLowerCase() == 'finished';

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
          Row(
            children: [
              Text(
                startText,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: finished
                      ? const Color(0x1A22C55E)
                      : chipInProgressBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: finished ? scoreGreen : chipInProgressText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(endText, style: TextStyle(fontSize: 12, color: mutedText)),
          const SizedBox(height: 8),
          Text(
            '${item.score}',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onViewResult,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Xatolarni ko‘rish'),
            ),
          ),
        ],
      ),
    );
  }
}
