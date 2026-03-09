import 'package:flutter/material.dart';
import 'package:uztelecom/domain/services/exams_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/utils/network_error.dart';

class ExamAttemptsPage extends StatefulWidget {
  final int examId;
  final String examTitle;

  const ExamAttemptsPage({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ExamAttemptsPage> createState() => _ExamAttemptsPageState();
}

class _ExamAttemptsPageState extends State<ExamAttemptsPage> {
  final ExamsService _service = ExamsService();
  late Future<List<ExamAttemptItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAttempts(widget.examId);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = _service.fetchAttempts(widget.examId));
  }

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y $hh:$mm';
  }

  String _statusText(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'finished':
        return tr(context, uz: 'Yakunlangan', ru: 'Завершен');
      case 'started':
      case 'in_progress':
        return tr(context, uz: 'Jarayonda', ru: 'В процессе');
      default:
        return status;
    }
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
        foregroundColor: scheme.onBackground,
        title: Text(
          tr(context, uz: 'Urinishlar tarixi', ru: 'История попыток'),
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
                ? tr(
                    context,
                    uz: "Internet yo'q. Qayta urinib ko'ring.",
                    ru: 'Нет интернета. Попробуйте снова.',
                  )
                : error.toString().replaceFirst('Exception: ', '');
            return _ErrorState(message: message, onRetry: _reload);
          }

          final attempts = snapshot.data ?? const <ExamAttemptItem>[];
          if (attempts.isEmpty) {
            return Center(
              child: Text(
                tr(
                  context,
                  uz: "Urinishlar hali yo'q.",
                  ru: 'Попыток пока нет.',
                ),
                style: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: attempts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = attempts[index];
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
                          tr(
                            context,
                            uz: 'Urinish #${item.attemptNumber}',
                            ru: 'Попытка #${item.attemptNumber}',
                          ),
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: finished
                                ? const Color(0x1A22C55E)
                                : const Color(0x1AF59E0B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusText(context, item.status),
                            style: TextStyle(
                              color: finished
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFB45309),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(
                        context,
                        uz: 'Boshlanish: ${_fmtDateTime(item.startTime)}',
                        ru: 'Начало: ${_fmtDateTime(item.startTime)}',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        context,
                        uz: 'Tugash: ${_fmtDateTime(item.endTime)}',
                        ru: 'Завершение: ${_fmtDateTime(item.endTime)}',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(
                        context,
                        uz: 'Ball: ${item.score}',
                        ru: 'Баллы: ${item.score}',
                      ),
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
                        onPressed: finished
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ExamResultPage(
                                      examId: widget.examId,
                                      examTitle: widget.examTitle,
                                      attemptNumber: item.attemptNumber,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.analytics_outlined),
                        label: Text(
                          tr(
                            context,
                            uz: "Xatolarni ko'rish",
                            ru: 'Посмотреть ошибки',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExamResultPage extends StatefulWidget {
  final int examId;
  final String examTitle;
  final int attemptNumber;

  const ExamResultPage({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.attemptNumber,
  });

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  final ExamsService _service = ExamsService();
  late Future<ExamResultDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchResult(
      examId: widget.examId,
      attemptNumber: widget.attemptNumber,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchResult(
        examId: widget.examId,
        attemptNumber: widget.attemptNumber,
      );
    });
  }

  int _correctCount(List<ExamResultQuestion> questions) {
    return questions.where((q) {
      for (final a in q.answers) {
        if (a.isSelected && a.isTrue) return true;
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
        foregroundColor: scheme.onBackground,
        title: Text(
          tr(context, uz: 'Natija', ru: 'Результат'),
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
                ? tr(
                    context,
                    uz: "Internet yo'q. Qayta urinib ko'ring.",
                    ru: 'Нет интернета. Попробуйте снова.',
                  )
                : error.toString().replaceFirst('Exception: ', '');
            return _ErrorState(message: message, onRetry: _reload);
          }

          final result = snapshot.data;
          if (result == null) {
            return _ErrorState(
              message: tr(
                context,
                uz: 'Natija topilmadi.',
                ru: 'Результат не найден.',
              ),
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        context,
                        uz: 'Urinish #${result.attemptNumber}',
                        ru: 'Попытка #${result.attemptNumber}',
                      ),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _ScoreChip(
                          text: tr(
                            context,
                            uz: 'Ball: ${result.score}/${result.maxScore}',
                            ru: 'Баллы: ${result.score}/${result.maxScore}',
                          ),
                          color: const Color(0xFF2F80FF),
                        ),
                        _ScoreChip(
                          text: tr(
                            context,
                            uz: "To'g'ri: $correct",
                            ru: 'Верно: $correct',
                          ),
                          color: const Color(0xFF16A34A),
                        ),
                        _ScoreChip(
                          text: tr(
                            context,
                            uz: 'Xato: $wrong',
                            ru: 'Ошибки: $wrong',
                          ),
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...result.questions.asMap().entries.map((entry) {
                final qIndex = entry.key + 1;
                final q = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResultQuestionCard(index: qIndex, question: q),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ResultQuestionCard extends StatelessWidget {
  final int index;
  final ExamResultQuestion question;

  const _ResultQuestionCard({required this.index, required this.question});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
          Text(
            tr(context, uz: 'Savol $index', ru: 'Вопрос $index'),
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.text,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...question.answers.asMap().entries.map((entry) {
            final answer = entry.value;
            final label = String.fromCharCode(65 + entry.key);
            final isCorrect = answer.isTrue;
            final isSelected = answer.isSelected;

            Color bgColor = const Color(0xFFF3F4F6);
            Color borderColor = const Color(0xFFE5E7EB);
            Color textColor = const Color(0xFF111827);
            IconData? trailing;
            Color trailingColor = const Color(0xFF6B7280);

            if (isSelected && isCorrect) {
              bgColor = const Color(0xFFE8F9EF);
              borderColor = const Color(0xFF16A34A);
              textColor = const Color(0xFF166534);
              trailing = Icons.check_circle;
              trailingColor = const Color(0xFF16A34A);
            } else if (isSelected && !isCorrect) {
              bgColor = const Color(0xFFFEECEC);
              borderColor = const Color(0xFFDC2626);
              textColor = const Color(0xFF991B1B);
              trailing = Icons.cancel;
              trailingColor = const Color(0xFFDC2626);
            } else if (!isSelected && isCorrect) {
              bgColor = const Color(0xFFEAF2FF);
              borderColor = const Color(0xFF2F80FF);
              textColor = const Color(0xFF1E3A8A);
              trailing = Icons.check_circle_outline;
              trailingColor = const Color(0xFF2F80FF);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        answer.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailing, size: 18, color: trailingColor),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String text;
  final Color color;

  const _ScoreChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(tr(context, uz: 'Qayta urinish', ru: 'Повторить')),
            ),
          ],
        ),
      ),
    );
  }
}
