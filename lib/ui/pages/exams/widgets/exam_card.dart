import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.attempts,
    required this.attemptsLeft,
    required this.canStart,
    required this.message,
    required this.isLoading,
    required this.onStart,
    required this.onAttempts,
  });

  final String title;
  final String subtitle;
  final int? attempts;
  final int? attemptsLeft;
  final bool canStart;
  final String? message;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback onAttempts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedText = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = Theme.of(context).dividerColor;
    final canStartEffective =
        canStart && (attemptsLeft == null || attemptsLeft! > 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fact_check_outlined, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: mutedText),
                      ),
                    ],
                    if (attempts != null || attemptsLeft != null) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          if (attempts != null)
                            Text(
                              tr(
                                context,
                                TrKey.urinishlar,
                                params: {'p1': attempts},
                              ),
                              style: TextStyle(fontSize: 12, color: mutedText),
                            ),
                          if (attemptsLeft != null)
                            Text(
                              tr(
                                context,
                                TrKey.qoldi,
                                params: {'p1': attemptsLeft},
                              ),
                              style: TextStyle(fontSize: 12, color: mutedText),
                            ),
                        ],
                      ),
                    ],
                    if (message != null && message!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        message!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: canStartEffective
                              ? mutedText
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAttempts,
                  icon: const Icon(Icons.history_rounded),
                  label: Text(tr(context, TrKey.urinishlar2)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: canStartEffective && !isLoading ? onStart : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : Text(tr(context, TrKey.startAction)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
