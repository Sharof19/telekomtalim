import 'package:flutter/material.dart';
import 'package:uztelecom/data/models/schedule_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

String scheduleWeekdayShortLabel(BuildContext context, String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return '--';
  switch (parsed.weekday) {
    case DateTime.monday:
      return tr(context, TrKey.du);
    case DateTime.tuesday:
      return tr(context, TrKey.se);
    case DateTime.wednesday:
      return tr(context, TrKey.ch);
    case DateTime.thursday:
      return tr(context, TrKey.pa);
    case DateTime.friday:
      return tr(context, TrKey.ju);
    case DateTime.saturday:
      return tr(context, TrKey.sh);
    case DateTime.sunday:
      return tr(context, TrKey.ya);
  }
  return '--';
}

String scheduleWeekdayFullLabel(BuildContext context, String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  switch (parsed.weekday) {
    case DateTime.monday:
      return tr(context, TrKey.dushanba);
    case DateTime.tuesday:
      return tr(context, TrKey.seshanba);
    case DateTime.wednesday:
      return tr(context, TrKey.chorshanba);
    case DateTime.thursday:
      return tr(context, TrKey.payshanba);
    case DateTime.friday:
      return tr(context, TrKey.juma);
    case DateTime.saturday:
      return tr(context, TrKey.shanba);
    case DateTime.sunday:
      return tr(context, TrKey.yakshanba);
  }
  return date;
}

String scheduleMonthName(BuildContext context, int month) {
  switch (month) {
    case 1:
      return tr(context, TrKey.yanvar);
    case 2:
      return tr(context, TrKey.fevral);
    case 3:
      return tr(context, TrKey.mart);
    case 4:
      return tr(context, TrKey.aprel);
    case 5:
      return tr(context, TrKey.may);
    case 6:
      return tr(context, TrKey.iyun);
    case 7:
      return tr(context, TrKey.iyul);
    case 8:
      return tr(context, TrKey.avgust);
    case 9:
      return tr(context, TrKey.sentabr);
    case 10:
      return tr(context, TrKey.oktabr);
    case 11:
      return tr(context, TrKey.noyabr);
    case 12:
      return tr(context, TrKey.dekabr);
  }
  return '';
}

String formatScheduleDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime startOfScheduleWeek(DateTime date) {
  final weekday = date.weekday;
  final monday = date.subtract(Duration(days: weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

ScheduleData filterScheduleWeek(
  ScheduleData data,
  DateTime weekStart,
  DateTime weekEnd,
) {
  final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final end = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
  final indices = <int>[];
  final columns = <ScheduleColumn>[];

  for (var i = 0; i < data.columns.length; i++) {
    final column = data.columns[i];
    final columnDate = DateTime.tryParse(column.date);
    if (columnDate == null) continue;
    if (columnDate.isBefore(start) || columnDate.isAfter(end)) continue;
    if (columnDate.weekday < DateTime.monday ||
        columnDate.weekday > DateTime.saturday) {
      continue;
    }
    indices.add(i);
    columns.add(column);
  }

  final rows = data.rows.map((row) {
    final filteredCells = <ScheduleCell>[];
    for (final index in indices) {
      if (index < row.cells.length) {
        filteredCells.add(row.cells[index]);
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
