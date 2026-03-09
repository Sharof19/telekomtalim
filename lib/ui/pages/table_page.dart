import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uztelecom/domain/services/bbb_service.dart';
import 'package:uztelecom/domain/services/login_service.dart';
import 'package:uztelecom/domain/services/schedule_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/no_internet_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => TablePageState();
}

class TablePageState extends State<TablePage> {
  final ScheduleService _service = ScheduleService();
  late Future<ScheduleData> _future;
  late DateTime _weekStart;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
    _future = _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<ScheduleData> _load() {
    final end = _weekStart.add(const Duration(days: 5));
    return _service.fetchSchedule(
      startDate: _fmtDate(_weekStart),
      endDate: _fmtDate(end),
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
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => NoInternetPage(
                onRetry: () {
                  Navigator.of(context).pop();
                  _offlinePushed = false;
                  refresh();
                },
              ),
            ),
          )
          .then((_) {
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConnectivityGate(child: NotificationsPage()),
      ),
    );
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
          tr(context, uz: 'Vebinarlar', ru: 'Вебинары'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              onPressed: _onNotificationsTap,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, uz: 'Xabarlar', ru: 'Уведомления'),
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
          return _EmptyState(
            message: tr(
              context,
              uz: "Jadvalni yuklashda xatolik. Qayta urinib ko'ring.",
              ru: 'Не удалось загрузить расписание. Попробуйте снова.',
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || data.columns.isEmpty || data.rows.isEmpty) {
          return _EmptyState(
            message: tr(
              context,
              uz: 'Dars jadvali hozircha mavjud emas.',
              ru: 'Расписание занятий пока недоступно.',
            ),
          );
        }
        final weekEnd = weekStart.add(const Duration(days: 5));
        final filtered = _filterWeek(data, weekStart, weekEnd);
        if (filtered.columns.isEmpty) {
          return _EmptyState(
            message: tr(
              context,
              uz: "Tanlangan hafta uchun darslar topilmadi.",
              ru: 'Для выбранной недели занятий нет.',
            ),
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
  final BbbService _bbbService = BbbService();
  final LoginService _loginService = LoginService();
  late int _selectedColumnIndex;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _bbbService.dispose();
    _loginService.dispose();
    super.dispose();
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

  List<_DayLessonItem> _selectedDayLessons() {
    if (widget.data.columns.isEmpty) return const [];
    final index = _selectedColumnIndex.clamp(0, widget.data.columns.length - 1);
    final result = <_DayLessonItem>[];
    for (final row in widget.data.rows) {
      if (index >= row.cells.length) continue;
      final cell = row.cells[index];
      if (!cell.hasLesson || cell.lesson == null) continue;
      result.add(_DayLessonItem(row: row, lesson: cell.lesson!));
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
      final url = await _bbbService.joinPublicMeeting(meetingId);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                context,
                uz: 'Miting linki topilmadi.',
                ru: 'Ссылка на встречу не найдена.',
              ),
            ),
          ),
        );
        return;
      }
      final uri = Uri.tryParse(url);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                context,
                uz: "Miting linki noto'g'ri.",
                ru: 'Неверная ссылка на встречу.',
              ),
            ),
          ),
        );
        return;
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                context,
                uz: 'Miting linki ochilmadi.',
                ru: 'Ссылка на встречу не открылась.',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(context, uz: 'Xatolik: $e', ru: 'Ошибка: $e')),
        ),
      );
    }
  }

  Future<void> _copyToken() async {
    String? token;
    try {
      token = await _loginService.getValidAccessToken();
    } catch (_) {
      token = null;
    }
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, uz: 'Token topilmadi.', ru: 'Токен не найден.'),
          ),
        ),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, uz: 'Token nusxalandi.', ru: 'Токен скопирован.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF0B1724)
        : const Color(0xFFF3F4F8);
    final headerTitle = isDark ? Colors.white : const Color(0xFF111827);
    final headerDate = isDark
        ? const Color(0xFF9AA6B2)
        : const Color(0xFF6B7280);
    final dayItemBg = isDark
        ? const Color(0xFF172638)
        : const Color(0xFFEAEAF1);
    final dayItemText = isDark
        ? const Color(0xFFD0D7E1)
        : const Color(0xFF20242C);
    final selectedDayBg = const Color(0xFF1292EE);
    final selectedDayText = Colors.white;

    final selectedColumn = widget
        .data
        .columns[_selectedColumnIndex.clamp(0, widget.data.columns.length - 1)];
    final selectedDate = DateTime.tryParse(selectedColumn.date);
    final selectedLessons = _selectedDayLessons();
    final dayHeader = selectedColumn.isToday
        ? tr(context, uz: 'Bugun', ru: 'Сегодня')
        : _weekdayFullLabel(context, selectedColumn.date);
    final dateHeader = selectedDate != null
        ? '${selectedDate.day} ${_monthName(context, selectedDate.month)}'
        : selectedColumn.date;

    return Container(
      color: background,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => widget.onShiftWeek(-1),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: headerTitle,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayHeader,
                        style: TextStyle(
                          color: headerTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateHeader,
                        style: TextStyle(
                          color: headerDate,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onShiftWeek(1),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: headerTitle,
                    size: 28,
                  ),
                ),
                if (kDebugMode)
                  IconButton(
                    onPressed: _copyToken,
                    icon: Icon(Icons.copy_rounded, color: headerDate, size: 20),
                    tooltip: tr(
                      context,
                      uz: 'Tokenni nusxalash',
                      ru: 'Скопировать токен',
                    ),
                  ),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (var i = 0; i < widget.data.columns.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedColumnIndex = i),
                        child: _DayStripItem(
                          column: widget.data.columns[i],
                          hasLessons: _columnHasLessons(i),
                          selected: i == _selectedColumnIndex,
                          selectedBg: selectedDayBg,
                          selectedText: selectedDayText,
                          normalBg: dayItemBg,
                          normalText: dayItemText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: selectedLessons.isEmpty
                  ? _DayEmptyState(
                      message: tr(
                        context,
                        uz: 'Bu kun uchun darslar yo‘q.',
                        ru: 'На этот день занятий нет.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: selectedLessons.length,
                      itemBuilder: (context, i) {
                        final item = selectedLessons[i];
                        final isFirst = i == 0;
                        final isLast = i == selectedLessons.length - 1;
                        return _TimelineLessonTile(
                          item: item,
                          isFirst: isFirst,
                          isLast: isLast,
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

class _DayStripItem extends StatelessWidget {
  final ScheduleColumn column;
  final bool hasLessons;
  final bool selected;
  final Color selectedBg;
  final Color selectedText;
  final Color normalBg;
  final Color normalText;

  const _DayStripItem({
    required this.column,
    required this.hasLessons,
    required this.selected,
    required this.selectedBg,
    required this.selectedText,
    required this.normalBg,
    required this.normalText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: selected ? selectedBg : normalBg,
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: selectedBg, width: 1.1) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _weekdayShortLabel(context, column.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? selectedText : normalText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            column.day.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? selectedText : normalText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasLessons) ...[
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF1292EE),
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.white, width: 1)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineLessonTile extends StatelessWidget {
  final _DayLessonItem item;
  final bool isFirst;
  final bool isLast;
  final void Function(String meetingId) onJoinMeeting;

  const _TimelineLessonTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.onJoinMeeting,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeColor = isDark
        ? const Color(0xFFA5B3C2)
        : const Color(0xFF7A808A);
    final lineColor = isDark
        ? const Color(0xFF36516B)
        : const Color(0xFFC7D3E0);
    final dotBorder = isDark
        ? const Color(0xFF2D3F53)
        : const Color(0xFFD5DEE8);
    final dotFill = const Color(0xFF1292EE);
    final cardBg = isDark ? const Color(0xFF1A2A3B) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subColor = isDark ? const Color(0xFFC4D0DD) : const Color(0xFF4B5563);
    final metaColor = isDark
        ? const Color(0xFF9BB0C4)
        : const Color(0xFF6B7280);
    final border = isDark ? const Color(0xFF2A3C50) : const Color(0xFFE7ECF2);
    final onlineColor = isDark
        ? const Color(0xFF77C2FF)
        : const Color(0xFF0E7BD5);
    final meetingId = item.lesson.bbbObject.meetingId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 74,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  item.startTimeLabel,
                  style: TextStyle(
                    color: timeColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 24,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 1.5,
                        color: isFirst && isLast
                            ? Colors.transparent
                            : lineColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: dotFill,
                        shape: BoxShape.circle,
                        border: Border.all(color: dotBorder, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.lesson.theme?.trim().isNotEmpty == true
                                ? item.lesson.theme!
                                : tr(context, uz: 'Dars', ru: 'Занятие'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (meetingId != null && meetingId.isNotEmpty)
                          InkWell(
                            onTap: () => onJoinMeeting(meetingId),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Icon(
                                Icons.video_call_rounded,
                                color: onlineColor,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if ((item.lesson.group ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.lesson.group!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: metaColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.row.time,
                          style: TextStyle(
                            color: metaColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if ((item.lesson.educationType ?? '').isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: metaColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.lesson.educationType!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: metaColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayLessonItem {
  final ScheduleRow row;
  final LessonInfo lesson;

  const _DayLessonItem({required this.row, required this.lesson});

  String get startTimeLabel {
    final raw = row.time.trim();
    if (raw.isEmpty) return '--:--';
    final parts = raw.split(RegExp(r'\s*-\s*'));
    return parts.first;
  }
}

class _DayEmptyState extends StatelessWidget {
  final String message;

  const _DayEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF96A8BB) : const Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 15),
      ),
    );
  }
}

String _weekdayShortLabel(BuildContext context, String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return '--';
  switch (parsed.weekday) {
    case DateTime.monday:
      return tr(context, uz: 'Du', ru: 'Пн');
    case DateTime.tuesday:
      return tr(context, uz: 'Se', ru: 'Вт');
    case DateTime.wednesday:
      return tr(context, uz: 'Ch', ru: 'Ср');
    case DateTime.thursday:
      return tr(context, uz: 'Pa', ru: 'Чт');
    case DateTime.friday:
      return tr(context, uz: 'Ju', ru: 'Пт');
    case DateTime.saturday:
      return tr(context, uz: 'Sh', ru: 'Сб');
    case DateTime.sunday:
      return tr(context, uz: 'Ya', ru: 'Вс');
  }
  return '--';
}

String _weekdayFullLabel(BuildContext context, String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  switch (parsed.weekday) {
    case DateTime.monday:
      return tr(context, uz: 'Dushanba', ru: 'Понедельник');
    case DateTime.tuesday:
      return tr(context, uz: 'Seshanba', ru: 'Вторник');
    case DateTime.wednesday:
      return tr(context, uz: 'Chorshanba', ru: 'Среда');
    case DateTime.thursday:
      return tr(context, uz: 'Payshanba', ru: 'Четверг');
    case DateTime.friday:
      return tr(context, uz: 'Juma', ru: 'Пятница');
    case DateTime.saturday:
      return tr(context, uz: 'Shanba', ru: 'Суббота');
    case DateTime.sunday:
      return tr(context, uz: 'Yakshanba', ru: 'Воскресенье');
  }
  return date;
}

String _monthName(BuildContext context, int month) {
  switch (month) {
    case 1:
      return tr(context, uz: 'yanvar', ru: 'января');
    case 2:
      return tr(context, uz: 'fevral', ru: 'февраля');
    case 3:
      return tr(context, uz: 'mart', ru: 'марта');
    case 4:
      return tr(context, uz: 'aprel', ru: 'апреля');
    case 5:
      return tr(context, uz: 'may', ru: 'мая');
    case 6:
      return tr(context, uz: 'iyun', ru: 'июня');
    case 7:
      return tr(context, uz: 'iyul', ru: 'июля');
    case 8:
      return tr(context, uz: 'avgust', ru: 'августа');
    case 9:
      return tr(context, uz: 'sentabr', ru: 'сентября');
    case 10:
      return tr(context, uz: 'oktabr', ru: 'октября');
    case 11:
      return tr(context, uz: 'noyabr', ru: 'ноября');
    case 12:
      return tr(context, uz: 'dekabr', ru: 'декабря');
  }
  return '';
}

String _fmtDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime _startOfWeek(DateTime date) {
  final weekday = date.weekday; // Mon=1..Sun=7
  final monday = date.subtract(Duration(days: weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

ScheduleData _filterWeek(
  ScheduleData data,
  DateTime weekStart,
  DateTime weekEnd,
) {
  final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final end = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
  final indices = <int>[];
  final columns = <ScheduleColumn>[];
  for (var i = 0; i < data.columns.length; i++) {
    final col = data.columns[i];
    DateTime? colDate;
    try {
      colDate = DateTime.parse(col.date);
    } catch (_) {
      colDate = null;
    }
    if (colDate == null) continue;
    if (colDate.isBefore(start) || colDate.isAfter(end)) continue;
    if (colDate.weekday < DateTime.monday ||
        colDate.weekday > DateTime.saturday) {
      continue;
    }
    indices.add(i);
    columns.add(col);
  }

  final rows = data.rows.map((row) {
    final filteredCells = <ScheduleCell>[];
    for (final idx in indices) {
      if (idx < row.cells.length) {
        filteredCells.add(row.cells[idx]);
      } else {
        filteredCells.add(const ScheduleCell(hasLesson: false));
      }
    }
    return ScheduleRow(
      pairId: row.pairId,
      label: row.label,
      time: row.time,
      cells: filteredCells,
    );
  }).toList();

  return ScheduleData(period: data.period, columns: columns, rows: rows);
}
