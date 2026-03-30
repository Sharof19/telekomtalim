import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uztelecom/data/repositories/exams_repository.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class ExamSessionPage extends StatefulWidget {
  final int examId;
  final ExamSession session;
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
  final ExamsRepository _examsService = ExamsRepository();
  late final List<int?> _selectedAnswerIds;
  late int _currentIndex;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _finishing = false;
  final Set<int> _savingQuestionIds = <int>{};

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _selectedAnswerIds = widget.session.questions.map((q) {
      final selected = q.answers.firstWhere(
        (a) => a.isSelected,
        orElse: () => const ExamAnswer(id: 0, text: '', isSelected: false),
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
    _examsService.dispose();
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
      await _examsService.saveAnswer(
        examId: widget.examId,
        questionId: question.id,
        answerId: answerId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
      final message = await _examsService.finishExam(examId: widget.examId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ??
                tr(
                  context,
                  uz: 'Imtihon muvaffaqiyatli tugatildi.',
                  ru: 'Экзамен успешно завершен.',
                ),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
          title: Text(
            tr(ctx, uz: 'Imtihonni tugatish', ru: 'Завершить экзамен'),
          ),
          content: Text(
            tr(
              ctx,
              uz: 'Imtihonni tugatishni xohlaysizmi?',
              ru: 'Вы хотите завершить экзамен?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(tr(ctx, uz: "Yo'q", ru: 'Нет')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(tr(ctx, uz: 'Ha', ru: 'Да')),
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
    final cardBg = isDark ? const Color(0xFF1F3E5B) : scheme.surface;
    final border = isDark
        ? const Color(0xFF2E5A7C)
        : Theme.of(context).dividerColor;
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
        foregroundColor: scheme.onBackground,
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
                  : Text(tr(context, uz: 'Tugatish', ru: 'Завершить')),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? Center(
              child: Text(
                tr(
                  context,
                  uz: 'Savollar topilmadi.',
                  ru: 'Вопросы не найдены.',
                ),
                style: TextStyle(color: scheme.onBackground.withOpacity(0.6)),
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
                            label: Text(
                              tr(context, uz: 'Oldingi savol', ru: 'Назад'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _currentIndex < questions.length - 1
                                ? () => setState(() => _currentIndex += 1)
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              tr(context, uz: 'Keyingi savol', ru: 'Далее'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F80FF),
                              foregroundColor: Colors.white,
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
    final scheme = Theme.of(context).colorScheme;
    final label = examAttemptId != null ? '#$examAttemptId' : '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, uz: 'Imtihon $label', ru: 'Экзамен $label'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr(
                    context,
                    uz: 'Urinish: ${attemptNumber ?? 1}',
                    ru: 'Попытка: ${attemptNumber ?? 1}',
                  ),
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tr(context, uz: 'Javob berilgan', ru: 'Отвечено'),
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              Text(
                '$answered / $total',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              _TimerBadge(seconds: remainingSeconds),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int seconds;

  const _TimerBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF204B7A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            '$minutes:$secs',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, uz: 'Savollar ro‘yxati', ru: 'Список вопросов'),
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
                        ? const Color(0xFF2F80FF)
                        : const Color(0xFF2B3E52),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
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

class _QuestionCard extends StatelessWidget {
  final ExamQuestion question;
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr(context, uz: 'Savol', ru: 'Вопрос'),
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.6),
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
                      color: Color(0xFF2FA97E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tr(context, uz: 'Javob berildi', ru: 'Отвечено'),
                      style: const TextStyle(
                        color: Color(0xFF2FA97E),
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
                          ? const Color(0xFF1E4E89)
                          : const Color(0xFF2B3E52),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2F80FF)
                            : const Color(0xFF385A77),
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
                                ? const Color(0xFF2F80FF)
                                : const Color(0xFF394E63),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            answer.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2F80FF),
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
