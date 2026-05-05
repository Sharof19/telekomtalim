import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/schedule_models.dart';
import 'package:uztelecom/ui/pages/schedule/widgets/schedule_date_utils.dart';

class ScheduleDayStrip extends StatelessWidget {
  final List<ScheduleColumn> columns;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool Function(int index) hasLessonsAt;

  const ScheduleDayStrip({
    super.key,
    required this.columns,
    required this.selectedIndex,
    required this.onSelected,
    required this.hasLessonsAt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalBg = isDark ? const Color(0xFF172638) : const Color(0xFFEAEAF1);
    final normalText = isDark
        ? const Color(0xFFD0D7E1)
        : const Color(0xFF20242C);
    const selectedBg = Color(0xFF1292EE);
    const selectedText = AppColors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: _ScheduleDayStripItem(
                  column: columns[i],
                  hasLessons: hasLessonsAt(i),
                  selected: i == selectedIndex,
                  selectedBg: selectedBg,
                  selectedText: selectedText,
                  normalBg: normalBg,
                  normalText: normalText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleDayStripItem extends StatelessWidget {
  final ScheduleColumn column;
  final bool hasLessons;
  final bool selected;
  final Color selectedBg;
  final Color selectedText;
  final Color normalBg;
  final Color normalText;

  const _ScheduleDayStripItem({
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
            scheduleWeekdayShortLabel(context, column.date),
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
                color: selectedBg,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: selectedText, width: 1)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
