class DashboardDayStat {
  final String date;
  final int total;

  const DashboardDayStat({required this.date, required this.total});

  factory DashboardDayStat.fromJson(Map<String, dynamic> json) {
    return DashboardDayStat(
      date: json['date']?.toString() ?? '',
      total: (json['total'] is num) ? (json['total'] as num).toInt() : 0,
    );
  }
}

class DashboardTimeStats {
  final List<DashboardDayStat> days;
  final int periodTotalSpentSeconds;
  final int totalSpentSeconds;

  const DashboardTimeStats({
    required this.days,
    required this.periodTotalSpentSeconds,
    required this.totalSpentSeconds,
  });

  factory DashboardTimeStats.fromJson(Map<String, dynamic> json) {
    final dayItems = json['days'] as List<dynamic>? ?? <dynamic>[];
    return DashboardTimeStats(
      days: dayItems
          .whereType<Map<String, dynamic>>()
          .map(DashboardDayStat.fromJson)
          .toList(),
      periodTotalSpentSeconds: (json['period_total_spent_seconds'] is num)
          ? (json['period_total_spent_seconds'] as num).toInt()
          : 0,
      totalSpentSeconds: (json['total_spent_seconds'] is num)
          ? (json['total_spent_seconds'] as num).toInt()
          : 0,
    );
  }
}
