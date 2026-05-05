class SchedulePeriod {
  final String startDate;
  final String endDate;

  const SchedulePeriod({required this.startDate, required this.endDate});

  factory SchedulePeriod.fromJson(Map<String, dynamic> json) {
    return SchedulePeriod(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }
}

class ScheduleColumn {
  final String date;
  final String label;
  final int day;
  final bool isToday;

  const ScheduleColumn({
    required this.date,
    required this.label,
    required this.day,
    required this.isToday,
  });

  factory ScheduleColumn.fromJson(Map<String, dynamic> json) {
    return ScheduleColumn(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      day: (json['day'] is num) ? (json['day'] as num).toInt() : 0,
      isToday: json['is_today'] == true,
    );
  }
}
