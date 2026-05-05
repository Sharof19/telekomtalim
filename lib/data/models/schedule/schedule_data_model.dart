import 'package:uztelecom/data/models/schedule/schedule_period_models.dart';
import 'package:uztelecom/data/models/schedule/schedule_row_models.dart';

class ScheduleData {
  final SchedulePeriod period;
  final List<ScheduleColumn> columns;
  final List<ScheduleRow> rows;

  const ScheduleData({
    required this.period,
    required this.columns,
    required this.rows,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    final periodJson = json['period'] as Map<String, dynamic>? ?? {};
    final columnsJson = json['columns'] as List<dynamic>? ?? [];
    final rowsJson = json['rows'] as List<dynamic>? ?? [];
    return ScheduleData(
      period: SchedulePeriod.fromJson(periodJson),
      columns: columnsJson
          .map(
            (entry) => ScheduleColumn.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      rows: rowsJson
          .map((entry) => ScheduleRow.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}
