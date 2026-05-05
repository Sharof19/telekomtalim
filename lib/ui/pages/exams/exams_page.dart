import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/exams/exam_use_cases.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/models/exam_models.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/exams/exam_session_data_mapper.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_card.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_empty_card.dart';
import 'package:uztelecom/ui/pages/exams/widgets/exam_empty_list_state.dart';
import 'package:uztelecom/ui/providers/exams/exams_provider.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/app_shimmer.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  late final ExamsProvider _provider;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _provider = ExamsProvider(
      loadExams: context.read<LoadExamsUseCase>(),
      startExam: context.read<StartExamUseCase>(),
    )..load();
  }

  void _reload() {
    _provider.load();
  }

  void _showOfflinePage() {
    if (_offlinePushed) return;
    _offlinePushed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppNavigator.pushNoInternetPage<void>(
        context,
        onRetry: () {
          Navigator.of(context).pop();
          _offlinePushed = false;
          _reload();
        },
      ).then((_) {
        _offlinePushed = false;
      });
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _startExam(ExamItem item) async {
    try {
      final result = await _provider.startExam(item);
      if (!mounted) return;

      final session = result.session;
      if (session == null || session.questions.isEmpty) {
        final message = result.message ?? tr(context, TrKey.imtihonBoshlandi);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      await AppNavigator.pushExamSession<bool>(
        context,
        examId: item.examId,
        session: examSessionDataFromSession(session),
        title: item.name,
      );

      if (mounted) {
        _reload();
      }
    } catch (e) {
      if (!mounted) return;
      final text = appFailureMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  String _formatRange(ExamItem item) {
    final begin = item.beginTime;
    final end = item.endTime;
    if (begin == null && end == null) return '';
    final startText = _formatDateTime(begin);
    final endText = _formatDateTime(end);
    if (startText.isEmpty) return endText;
    if (endText.isEmpty) return startText;
    return '$startText • $endText';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  Future<void> _openAttempts(ExamItem item) async {
    await AppNavigator.pushExamAttempts<void>(
      context,
      examId: item.examId,
      examTitle: item.name,
    );
  }

  void _openNotifications() {
    AppNavigator.pushNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return ChangeNotifierProvider<ExamsProvider>.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          foregroundColor: scheme.onSurface,
          title: Text(
            tr(context, TrKey.exams),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: _openNotifications,
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: tr(context, TrKey.notifications),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Consumer<ExamsProvider>(
            builder: (context, provider, _) {
              final error = provider.error;
              if (provider.isLoading) {
                return const ListCardsSkeleton(
                  itemCount: 4,
                  imageWidth: 0,
                  itemHeight: 118,
                );
              }

              if (error != null) {
                if (isNoInternetError(error)) {
                  _showOfflinePage();
                  return const SizedBox.shrink();
                }
                return ExamEmptyCard(
                  message: tr(
                    context,
                    TrKey.imtihonlarniYuklashdaXatolikQaytaUrinib,
                  ),
                  isError: true,
                );
              }

              final result = provider.result;
              if (result == null || result.items.isEmpty) {
                return const ExamEmptyListState();
              }

              return ListView.separated(
                itemCount: result.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = result.items[index];
                  return ExamCard(
                    title: item.name,
                    subtitle: _formatRange(item),
                    attempts: item.attempts,
                    attemptsLeft: item.attemptsLeft,
                    canStart: item.canStart,
                    message: item.message,
                    isLoading: provider.isStarting(item.examId),
                    onStart: () => _startExam(item),
                    onAttempts: () => _openAttempts(item),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
