import 'package:flutter/material.dart';
import 'package:uztelecom/domain/services/exams_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exam_attempts_page.dart';
import 'package:uztelecom/ui/pages/exam_session_page.dart';
import 'package:uztelecom/ui/pages/no_internet_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  final ExamsService _examsService = ExamsService();
  late Future<ExamsResult> _future;
  final Set<int> _starting = {};
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _future = _examsService.fetchMyExams();
  }

  void _reload() {
    setState(() {
      _future = _examsService.fetchMyExams();
    });
  }

  void _showOfflinePage() {
    if (_offlinePushed) return;
    _offlinePushed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => NoInternetPage(
                onRetry: () {
                  Navigator.of(context).pop();
                  _offlinePushed = false;
                  _reload();
                },
              ),
            ),
          )
          .then((_) {
            _offlinePushed = false;
          });
    });
  }

  @override
  void dispose() {
    _examsService.dispose();
    super.dispose();
  }

  Future<void> _startExam(ExamItem item) async {
    if (_starting.contains(item.examId)) return;
    setState(() => _starting.add(item.examId));
    try {
      final result = await _examsService.startExam(item.examId);
      if (!mounted) return;
      final session = result.session;
      if (session == null || session.questions.isEmpty) {
        final message =
            result.message ??
            tr(context, uz: 'Imtihon boshlandi.', ru: 'Экзамен начат.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamSessionPage(
            examId: item.examId,
            session: session,
            title: item.name,
          ),
        ),
      );
      if (mounted) {
        _reload();
      }
    } catch (e) {
      if (!mounted) return;
      final text = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    } finally {
      if (mounted) {
        setState(() => _starting.remove(item.examId));
      }
    }
  }

  String _formatRange(ExamItem item) {
    final begin = item.beginTime;
    final end = item.endTime;
    if (begin == null && end == null) return '';
    final startText = begin != null ? _fmtDateTime(begin) : '';
    final endText = end != null ? _fmtDateTime(end) : '';
    if (startText.isEmpty) return endText;
    if (endText.isEmpty) return startText;
    return '$startText • $endText';
  }

  String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y $hh:$mm';
  }

  Future<void> _openAttempts(ExamItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ExamAttemptsPage(examId: item.examId, examTitle: item.name),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConnectivityGate(child: NotificationsPage()),
      ),
    );
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
          tr(context, uz: 'Imtihonlar', ru: 'Экзамены'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, uz: 'Xabarlar', ru: 'Уведомления'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<ExamsResult>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    );
                  }
                  if (snapshot.hasError) {
                    final error = snapshot.error!;
                    if (isNoInternetError(error)) {
                      _showOfflinePage();
                      return const SizedBox.shrink();
                    }
                    return _EmptyCard(
                      message: tr(
                        context,
                        uz: 'Imtihonlarni yuklashda xatolik. Qayta urinib ko\'ring.',
                        ru: 'Не удалось загрузить экзамены. Попробуйте снова.',
                      ),
                      isError: true,
                    );
                  }
                  final result = snapshot.data;
                  if (result == null || result.items.isEmpty) {
                    return const _EmptyExamListState();
                  }
                  return ListView.separated(
                    itemCount: result.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ExamItem item = result.items[index];
                      final isLoading = _starting.contains(item.examId);
                      final subtitle = _formatRange(item);
                      return _ExamCard(
                        title: item.name,
                        subtitle: subtitle,
                        attempts: item.attempts,
                        attemptsLeft: item.attemptsLeft,
                        canStart: item.canStart,
                        message: item.message,
                        isLoading: isLoading,
                        onStart: () => _startExam(item),
                        onAttempts: () => _openAttempts(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final bool isError;

  const _EmptyCard({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isError ? Colors.redAccent : scheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _EmptyExamListState extends StatelessWidget {
  const _EmptyExamListState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEBFF),
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
            tr(context, uz: 'Imtihonlar topilmadi', ru: 'Экзамены не найдены'),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: scheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            tr(
              context,
              uz: 'Hozircha sizga tayinlangan imtihonlar yo\'q',
              ru: 'Пока вам не назначены экзамены',
            ),
            style: TextStyle(
              fontSize: 18,
              color: scheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? attempts;
  final int? attemptsLeft;
  final bool canStart;
  final String? message;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback onAttempts;

  const _ExamCard({
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                  color: scheme.primary.withOpacity(0.12),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
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
                                uz: 'Urinishlar: $attempts',
                                ru: 'Попытки: $attempts',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          if (attemptsLeft != null)
                            Text(
                              tr(
                                context,
                                uz: 'Qoldi: $attemptsLeft',
                                ru: 'Осталось: $attemptsLeft',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
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
                              ? scheme.onSurface.withOpacity(0.6)
                              : Colors.redAccent,
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
                  label: Text(tr(context, uz: 'Urinishlar', ru: 'Попытки')),
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
                      : Text(tr(context, uz: 'Boshlash', ru: 'Начать')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
