import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uztelecom/application/use_cases/auth/get_valid_access_token_use_case.dart';
import 'package:uztelecom/application/use_cases/schedule/schedule_use_cases.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/schedule_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/ui/pages/schedule/widgets/schedule_date_utils.dart';
import 'package:uztelecom/ui/pages/schedule/widgets/schedule_day_strip.dart';
import 'package:uztelecom/ui/pages/schedule/widgets/schedule_empty_state.dart';
import 'package:uztelecom/ui/pages/schedule/widgets/schedule_timeline_lesson_tile.dart';
import 'package:uztelecom/ui/pages/schedule/widgets/schedule_week_header.dart';
import 'package:uztelecom/ui/utils/network_error.dart';

class WebinarsPage extends StatefulWidget {
  const WebinarsPage({super.key});

  @override
  State<WebinarsPage> createState() => WebinarsPageState();
}

class WebinarsPageState extends State<WebinarsPage> {
  late final LoadScheduleUseCase _loadSchedule;
  late Future<ScheduleData> _future;
  late DateTime _weekStart;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule = context.read<LoadScheduleUseCase>();
    _weekStart = startOfScheduleWeek(DateTime.now());
    _future = _load();
  }

  Future<ScheduleData> _load() {
    final end = _weekStart.add(const Duration(days: 5));
    return _loadSchedule(
      startDate: formatScheduleDate(_weekStart),
      endDate: formatScheduleDate(end),
    );
  }

  void refresh() {
    setState(() {
      _future = _load();
    });
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
          refresh();
        },
      ).then((_) {
        _offlinePushed = false;
      });
    });
  }

  void _shiftWeek(int deltaWeeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * deltaWeeks));
      _future = _load();
    });
  }

  void _onNotificationsTap() {
    AppNavigator.pushNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final onBg = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: onBg,
        title: Text(
          tr(context, TrKey.webinars),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              onPressed: _onNotificationsTap,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, TrKey.notifications),
            ),
          ),
        ],
      ),
      body: _ScheduleBody(
        future: _future,
        weekStart: _weekStart,
        onNoInternet: _showOfflinePage,
        onShiftWeek: _shiftWeek,
      ),
    );
  }
}

class _ScheduleBody extends StatelessWidget {
  final Future<ScheduleData> future;
  final DateTime weekStart;
  final VoidCallback onNoInternet;
  final void Function(int deltaWeeks) onShiftWeek;

  const _ScheduleBody({
    required this.future,
    required this.weekStart,
    required this.onNoInternet,
    required this.onShiftWeek,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ScheduleData>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error!;
          if (isNoInternetError(error)) {
            onNoInternet();
            return const SizedBox.shrink();
          }
          return ScheduleEmptyState(
            message: tr(context, TrKey.jadvalniYuklashdaXatolikQaytaUrinib),
          );
        }
        final data = snapshot.data;
        if (data == null || data.columns.isEmpty || data.rows.isEmpty) {
          return ScheduleEmptyState(
            message: tr(context, TrKey.darsJadvaliHozirchaMavjudEmas),
          );
        }
        final weekEnd = weekStart.add(const Duration(days: 5));
        final filtered = filterScheduleWeek(data, weekStart, weekEnd);
        if (filtered.columns.isEmpty) {
          return ScheduleEmptyState(
            message: tr(context, TrKey.tanlanganHaftaUchunDarslarTopilmadi),
          );
        }
        return _TimetableView(data: filtered, onShiftWeek: onShiftWeek);
      },
    );
  }
}

class _TimetableView extends StatefulWidget {
  final ScheduleData data;
  final void Function(int deltaWeeks) onShiftWeek;

  const _TimetableView({required this.data, required this.onShiftWeek});

  @override
  State<_TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<_TimetableView> {
  late final JoinPublicMeetingUseCase _joinPublicMeeting;
  late final GetValidAccessTokenUseCase _getValidAccessToken;
  late int _selectedColumnIndex;

  @override
  void initState() {
    super.initState();
    _joinPublicMeeting = context.read<JoinPublicMeetingUseCase>();
    _getValidAccessToken = context.read<GetValidAccessTokenUseCase>();
    _selectedColumnIndex = _initialColumnIndex(widget.data);
  }

  @override
  void didUpdateWidget(covariant _TimetableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.columns == oldWidget.data.columns) return;
    final oldDate =
        (oldWidget.data.columns.isNotEmpty &&
            _selectedColumnIndex < oldWidget.data.columns.length)
        ? oldWidget.data.columns[_selectedColumnIndex].date
        : null;
    _selectedColumnIndex =
        _indexByDate(widget.data, oldDate) ?? _initialColumnIndex(widget.data);
  }

  int _initialColumnIndex(ScheduleData data) {
    if (data.columns.isEmpty) return 0;
    final todayIndex = data.columns.indexWhere((c) => c.isToday);
    return todayIndex >= 0 ? todayIndex : 0;
  }

  int? _indexByDate(ScheduleData data, String? date) {
    if (date == null || date.isEmpty) return null;
    final idx = data.columns.indexWhere((c) => c.date == date);
    return idx >= 0 ? idx : null;
  }

  List<ScheduleDayLessonItem> _selectedDayLessons() {
    if (widget.data.columns.isEmpty) return const [];
    final index = _selectedColumnIndex.clamp(0, widget.data.columns.length - 1);
    final result = <ScheduleDayLessonItem>[];
    for (final row in widget.data.rows) {
      if (index >= row.cells.length) continue;
      final cell = row.cells[index];
      if (!cell.hasLesson || cell.lesson == null) continue;
      result.add(ScheduleDayLessonItem(row: row, lesson: cell.lesson!));
    }
    return result;
  }

  bool _columnHasLessons(int columnIndex) {
    for (final row in widget.data.rows) {
      if (columnIndex >= row.cells.length) continue;
      if (row.cells[columnIndex].hasLesson) return true;
    }
    return false;
  }

  Future<void> _joinMeeting(String meetingId) async {
    try {
      final url = await _joinPublicMeeting(meetingId);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, TrKey.mitingLinkiTopilmadi))),
        );
        return;
      }
      final uri = Uri.tryParse(url);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, TrKey.mitingLinkiNotogri))),
        );
        return;
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, TrKey.mitingLinkiOchilmadi))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, TrKey.xatolik, params: {'p1': appFailureMessage(e)}),
          ),
        ),
      );
    }
  }

  Future<void> _copyToken() async {
    String? token;
    try {
      token = await _getValidAccessToken();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to copy debug auth token from webinars page.',
        error: error,
        stackTrace: stackTrace,
      );
      token = null;
    }
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.tokenTopilmadi))),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tr(context, TrKey.tokenNusxalandi))));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkBackground
        : const Color(0xFFF3F4F8);

    final selectedColumn = widget
        .data
        .columns[_selectedColumnIndex.clamp(0, widget.data.columns.length - 1)];
    final selectedDate = DateTime.tryParse(selectedColumn.date);
    final selectedLessons = _selectedDayLessons();
    final dayHeader = selectedColumn.isToday
        ? tr(context, TrKey.bugun)
        : scheduleWeekdayFullLabel(context, selectedColumn.date);
    final dateHeader = selectedDate != null
        ? '${selectedDate.day} ${scheduleMonthName(context, selectedDate.month)}'
        : selectedColumn.date;

    return Container(
      color: background,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            ScheduleWeekHeader(
              dayHeader: dayHeader,
              dateHeader: dateHeader,
              onPreviousWeek: () => widget.onShiftWeek(-1),
              onNextWeek: () => widget.onShiftWeek(1),
              showCopyTokenAction: kDebugMode,
              onCopyToken: _copyToken,
            ),
            const SizedBox(height: 10),
            ScheduleDayStrip(
              columns: widget.data.columns,
              selectedIndex: _selectedColumnIndex,
              onSelected: (index) =>
                  setState(() => _selectedColumnIndex = index),
              hasLessonsAt: _columnHasLessons,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: selectedLessons.isEmpty
                  ? ScheduleDayEmptyState(
                      message: tr(context, TrKey.buKunUchunDarslarYoq),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: selectedLessons.length,
                      itemBuilder: (context, i) {
                        final item = selectedLessons[i];
                        return ScheduleTimelineLessonTile(
                          item: item,
                          isFirst: i == 0,
                          isLast: i == selectedLessons.length - 1,
                          onJoinMeeting: _joinMeeting,
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
