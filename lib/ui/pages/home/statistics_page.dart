import 'package:flutter/material.dart';
import 'package:uztelecom/ui/pages/home/widgets/stats_progress_card.dart';
import 'package:uztelecom/ui/pages/home/widgets/stats_weekly_attendance_card.dart';
import 'package:uztelecom/ui/pages/home/widgets/stats_weekly_view_card.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

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
          tr(context, TrKey.statistikalar),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            const StatsProgressCard(),
            const SizedBox(height: 14),
            const StatsWeeklyAttendanceCard(),
            const SizedBox(height: 14),
            const StatsWeeklyViewCard(),
          ],
        ),
      ),
    );
  }
}
