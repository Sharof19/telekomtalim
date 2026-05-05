import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_attempt_card.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_error_state.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_palette.dart';
import 'package:uztelecom/ui/utils/network_error.dart';

class ExamAttemptsPage extends StatefulWidget {
  const ExamAttemptsPage({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  final int examId;
  final String examTitle;

  @override
  State<ExamAttemptsPage> createState() => _ExamAttemptsPageState();
}

class _ExamAttemptsPageState extends State<ExamAttemptsPage> {
  late final LoadExamAttemptsUseCase _loadExamAttempts;
  late Future<List<ExamAttemptItem>> _future;

  @override
  void initState() {
    super.initState();
    _loadExamAttempts = context.read<LoadExamAttemptsUseCase>();
    _future = _loadExamAttempts(widget.examId);
  }

  void _reload() {
    setState(() {
      _future = _loadExamAttempts(widget.examId);
    });
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _statusText(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'finished':
        return tr(context, TrKey.yakunlangan);
      case 'started':
      case 'in_progress':
        return tr(context, TrKey.jarayonda);
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ExamPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          tr(context, TrKey.urinishlarTarixi),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<ExamAttemptItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error!;
            final message = isNoInternetError(error)
                ? tr(context, TrKey.internetYoqQaytaUrinibKoring)
                : appFailureMessage(error);
            return ExamErrorState(message: message, onRetry: _reload);
          }

          final attempts = snapshot.data ?? const <ExamAttemptItem>[];
          if (attempts.isEmpty) {
            return Center(
              child: Text(
                tr(context, TrKey.urinishlarHaliYoq),
                style: TextStyle(color: palette.mutedText),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: attempts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = attempts[index];
              return ExamAttemptCard(
                item: item,
                statusText: _statusText(context, item.status),
                startText: tr(
                  context,
                  TrKey.boshlanish,
                  params: {'p1': _formatDateTime(item.startTime)},
                ),
                endText: tr(
                  context,
                  TrKey.tugash,
                  params: {'p1': _formatDateTime(item.endTime)},
                ),
                mutedText: palette.mutedText,
                scoreGreen: palette.scoreGreen,
                chipInProgressBackground: palette.chipInProgressBackground,
                chipInProgressText: palette.chipInProgressText,
                onViewResult: item.status.toLowerCase() == 'finished'
                    ? () {
                        AppNavigator.pushExamResult(
                          context,
                          examId: widget.examId,
                          examTitle: widget.examTitle,
                          attemptNumber: item.attemptNumber,
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
