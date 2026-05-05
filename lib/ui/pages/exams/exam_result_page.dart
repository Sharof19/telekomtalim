import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_error_state.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_result_question_card.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_result_summary_card.dart';
import 'package:uztelecom/ui/utils/network_error.dart';

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.attemptNumber,
  });

  final int examId;
  final String examTitle;
  final int attemptNumber;

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  late final LoadExamResultUseCase _loadExamResult;
  late Future<ExamResultDetail> _future;

  @override
  void initState() {
    super.initState();
    _loadExamResult = context.read<LoadExamResultUseCase>();
    _future = _loadExamResult(
      examId: widget.examId,
      attemptNumber: widget.attemptNumber,
    );
  }

  void _reload() {
    setState(() {
      _future = _loadExamResult(
        examId: widget.examId,
        attemptNumber: widget.attemptNumber,
      );
    });
  }

  int _correctCount(List<ExamResultQuestion> questions) {
    return questions.where((question) {
      for (final answer in question.answers) {
        if (answer.isSelected && answer.isTrue) {
          return true;
        }
      }
      return false;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          tr(context, TrKey.natija),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<ExamResultDetail>(
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

          final result = snapshot.data;
          if (result == null) {
            return ExamErrorState(
              message: tr(context, TrKey.natijaTopilmadi),
              onRetry: _reload,
            );
          }

          final correct = _correctCount(result.questions);
          final wrong = (result.questions.length - correct).clamp(
            0,
            result.questions.length,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              ExamResultSummaryCard(
                attemptNumber: result.attemptNumber,
                score: result.score,
                maxScore: result.maxScore,
                correctCount: correct,
                wrongCount: wrong,
              ),
              const SizedBox(height: 12),
              ...result.questions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExamResultQuestionCard(
                    index: entry.key + 1,
                    question: entry.value,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
