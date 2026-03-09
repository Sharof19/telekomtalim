import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final onBg = Theme.of(context).colorScheme.onBackground;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: onBg,
        title: Text(
          tr(context, uz: 'Statistikalar', ru: 'Статистика'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            const _ProgressCard(),
            const SizedBox(height: 14),
            const _WeeklyAttendanceCard(),
            const SizedBox(height: 14),
            const _WeeklyViewCard(),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final cardBg = isDark ? const Color(0xFF0F2D4B) : Colors.white;
    final border = isDark ? const Color(0xFF1D4A72) : const Color(0xFFE3E6EF);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? const Color(0xFFB9C9DB) : Colors.black54;
    final ringBg = isDark ? const Color(0xFF223B57) : const Color(0xFFE7ECF5);
    final ringFg = isDark ? const Color(0xFF2FE36A) : scheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    color: ringBg,
                  ),
                ),
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 10,
                    color: ringFg,
                  ),
                ),
                Text(
                  '70%',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, color: textMuted, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      tr(context, uz: "O‘rganish jarayoni", ru: 'Процесс обучения'),
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tr(context, uz: 'Tugatilgan kurslar', ru: 'Завершенные курсы'),
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '7/10',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyAttendanceCard extends StatelessWidget {
  const _WeeklyAttendanceCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF233A68) : Colors.white;
    final border = isDark ? const Color(0xFF2E4E85) : const Color(0xFFE3E6EF);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final muted = isDark ? const Color(0xFFB9C9DB) : Colors.black54;
    final chipBg = isDark ? const Color(0xFF2E4470) : const Color(0xFFF1F3F7);
    final chipText = isDark ? Colors.white70 : Colors.black54;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr(
                    context,
                    uz: 'Haftalik qatnashish',
                    ru: 'Еженедельная посещаемость',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: chipText, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr(context, uz: '1-8 Noyabr 2025', ru: '1-8 Ноября 2025'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: chipText, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: chipText, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(context, uz: '4/4 hafta', ru: '4/4 недели'),
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 6.0;
              final availableWidth = constraints.maxWidth;
              final rawWidth = (availableWidth - gap * 6) / 7;
              final chipWidth = rawWidth > 0 ? rawWidth : 0.0;
              return Row(
                children: [
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Du', ru: 'Пн'),
                    day: '29',
                    selected: true,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Se', ru: 'Вт'),
                    day: '30',
                    selected: true,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Ch', ru: 'Ср'),
                    day: '31',
                    selected: false,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Pa', ru: 'Чт'),
                    day: '1',
                    selected: true,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Ju', ru: 'Пт'),
                    day: '2',
                    selected: false,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Sh', ru: 'Сб'),
                    day: '3',
                    selected: false,
                  ),
                  const SizedBox(width: gap),
                  _DayChip(
                    width: chipWidth,
                    label: tr(context, uz: 'Ya', ru: 'Вс'),
                    day: '4',
                    selected: false,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeeklyViewCard extends StatelessWidget {
  const _WeeklyViewCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF233A68) : Colors.white;
    final border = isDark ? const Color(0xFF2E4E85) : const Color(0xFFE3E6EF);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final muted = isDark ? const Color(0xFFB9C9DB) : Colors.black54;
    final chipBg = isDark ? const Color(0xFF2E4470) : const Color(0xFFF1F3F7);
    final chipText = isDark ? Colors.white70 : Colors.black54;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr(context, uz: 'Haftalik ko‘rish', ru: 'Еженедельный просмотр'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: chipText, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr(context, uz: '1-8 Noyabr 2025', ru: '1-8 Ноября 2025'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: chipText, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: chipText, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(context, uz: '4/4 hafta', ru: '4/4 недели'),
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _Bar(label: '8', value: 0.45),
              _Bar(label: '6', value: 0.35),
              _Bar(label: '7', value: 0.6, highlighted: true),
              _Bar(label: '4', value: 0.28),
              _Bar(label: '5', value: 0.42),
              _Bar(label: '3', value: 0.22),
              _Bar(label: '6', value: 0.35),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final String day;
  final bool selected;
  final double width;

  const _DayChip({
    required this.label,
    required this.day,
    required this.selected,
    this.width = 42,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? scheme.primary.withOpacity(isDark ? 0.7 : 0.2)
        : (isDark ? const Color(0xFF1B2F52) : const Color(0xFFF1F3F7));
    final border =
        isDark ? const Color(0xFF2B517B) : const Color(0xFFE3E6EF);
    final labelColor =
        isDark ? const Color(0xFFB9C9DB) : Colors.black54;
    final dayColor = isDark ? Colors.white : Colors.black87;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(
              color: dayColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final bool highlighted;

  const _Bar({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = highlighted
        ? scheme.primary
        : (isDark ? const Color(0xFF3B4F73) : const Color(0xFFE0E6F0));
    final labelColor =
        isDark ? const Color(0xFFB9C9DB) : Colors.black54;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 90 * value,
            width: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(context, uz: '$label soat', ru: '$label ч'),
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
