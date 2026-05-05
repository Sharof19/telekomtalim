import 'package:uztelecom/data/models/schedule/schedule_lesson_models.dart';

class ScheduleRow {
  final int pairId;
  final String label;
  final String time;
  final List<ScheduleCell> cells;

  const ScheduleRow({
    required this.pairId,
    required this.label,
    required this.time,
    required this.cells,
  });

  factory ScheduleRow.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List<dynamic>? ?? [];
    return ScheduleRow(
      pairId: (json['pair_id'] is num) ? (json['pair_id'] as num).toInt() : 0,
      label: json['label']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      cells: cellsJson
          .map((entry) => ScheduleCell.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}
