import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/routing/app_route_args.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_question_card.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_question_picker.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_session_header_card.dart';

class ExamSessionPage extends StatefulWidget {
  final int examId;
  final ExamSessionData session;
  final String title;

  const ExamSessionPage({
    super.key,
    required this.examId,
    required this.session,
    required this.title,
  });

  @override
  State<ExamSessionPage> createState() => _ExamSessionPageState();
}

class _ExamSessionPageState extends State<ExamSessionPage> {
  late final SaveExamAnswerUseCase _saveExamAnswer;
  late final FinishExamUseCase _finishExamUseCase;
  late final List<int?> _selectedAnswerIds;
  late int _currentIndex;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _finishing = false;
  final Set<int> _savingQuestionIds = <int>{};

  @override
  void initState() {
    super.initState();
    _saveExamAnswer = context.read<SaveExamAnswerUseCase>();
    _finishExamUseCase = context.read<FinishExamUseCase>();
    _currentIndex = 0;
    _selectedAnswerIds = widget.session.questions.map((q) {
      final selected = q.answers.firstWhere(
        (a) => a.isSelected,
        orElse: () => const ExamAnswerData(id: 0, text: '', isSelected: false),
      );
      return selected.id == 0 ? null : selected.id;
    }).toList();
    _remainingSeconds = widget.session.remainingTime ?? 0;
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _finishExam(auto: true);
          return;
        }
        setState(() => _remainingSeconds -= 1);
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _finishExam(auto: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onSelectAnswer(int answerId) async {
    if (_finishing) return;
    if (_currentIndex < 0 || _currentIndex >= widget.session.questions.length) {
      return;
    }
    final question = widget.session.questions[_currentIndex];
    setState(() {
      _selectedAnswerIds[_currentIndex] = answerId;
      _savingQuestionIds.add(question.id);
    });

    try {
      await _saveExamAnswer(
        examId: widget.examId,
        questionId: question.id,
        answerId: answerId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appFailureMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _savingQuestionIds.remove(question.id));
      }
    }
  }

  Future<void> _finishExam({bool auto = false}) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    _timer?.cancel();

    try {
      final message = await _finishExamUseCase(examId: widget.examId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ?? tr(context, TrKey.imtihonMuvaffaqiyatliTugatildi),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appFailureMessage(e))));
      setState(() => _finishing = false);
      if (auto && _remainingSeconds <= 0) {
        setState(() => _remainingSeconds = 1);
      }
    }
  }

  Future<void> _confirmFinish() async {
    if (_finishing) return;
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(tr(ctx, TrKey.imtihonniTugatish)),
          content: Text(tr(ctx, TrKey.imtihonniTugatishniXohlaysizmi)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(tr(ctx, TrKey.noAction)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(tr(ctx, TrKey.yesAction)),
            ),
          ],
        );
      },
    );
    if (shouldFinish == true) {
      await _finishExam();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF1F3E5B) : AppColors.white;
    final border = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;
    final mutedText = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final questions = widget.session.questions;
    final answeredCount = _selectedAnswerIds.where((e) => e != null).length;
    final current = questions.isNotEmpty ? questions[_currentIndex] : null;
    final isSavingCurrent =
        current != null && _savingQuestionIds.contains(current.id);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: _finishing ? null : _confirmFinish,
              child: _finishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(tr(context, TrKey.finishAction)),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? Center(
              child: Text(
                tr(context, TrKey.savollarTopilmadi),
                style: TextStyle(color: mutedText),
              ),
            )
          : SafeArea(
              top: false,
              left: false,
              right: false,
              minimum: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(
                      bg: cardBg,
                      border: border,
                      attemptNumber: widget.session.attemptNumber,
                      examAttemptId: widget.session.examAttemptId,
                      answered: answeredCount,
                      total: questions.length,
                      remainingSeconds: _remainingSeconds,
                    ),
                    const SizedBox(height: 12),
                    _QuestionPicker(
                      bg: cardBg,
                      border: border,
                      currentIndex: _currentIndex,
                      total: questions.length,
                      onSelect: (index) =>
                          setState(() => _currentIndex = index),
                    ),
                    const SizedBox(height: 12),
                    if (current != null)
                      Expanded(
                        child: _QuestionCard(
                          question: current,
                          bg: cardBg,
                          border: border,
                          selectedAnswerId: _selectedAnswerIds[_currentIndex],
                          isSaving: isSavingCurrent,
                          onSelect: _onSelectAnswer,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _currentIndex > 0
                                ? () => setState(() => _currentIndex -= 1)
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: Text(tr(context, TrKey.oldingiSavol)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _currentIndex < questions.length - 1
                                ? () => setState(() => _currentIndex += 1)
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(tr(context, TrKey.keyingiSavol)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandBlue,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Color bg;
  final Color border;
  final int? attemptNumber;
  final int? examAttemptId;
  final int answered;
  final int total;
  final int remainingSeconds;

  const _HeaderCard({
    required this.bg,
    required this.border,
    required this.attemptNumber,
    required this.examAttemptId,
    required this.answered,
    required this.total,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return ExamSessionHeaderCard(
      backgroundColor: bg,
      borderColor: border,
      attemptNumber: attemptNumber,
      examAttemptId: examAttemptId,
      answered: answered,
      total: total,
      remainingSeconds: remainingSeconds,
    );
  }
}

class _QuestionPicker extends StatelessWidget {
  final Color bg;
  final Color border;
  final int currentIndex;
  final int total;
  final ValueChanged<int> onSelect;

  const _QuestionPicker({
    required this.bg,
    required this.border,
    required this.currentIndex,
    required this.total,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ExamQuestionPicker(
      backgroundColor: bg,
      borderColor: border,
      currentIndex: currentIndex,
      total: total,
      onSelect: onSelect,
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final ExamQuestionData question;
  final Color bg;
  final Color border;
  final int? selectedAnswerId;
  final bool isSaving;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.question,
    required this.bg,
    required this.border,
    required this.selectedAnswerId,
    required this.isSaving,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ExamQuestionCard(
      question: question,
      backgroundColor: bg,
      borderColor: border,
      selectedAnswerId: selectedAnswerId,
      isSaving: isSaving,
      onSelect: onSelect,
    );
  }
}
