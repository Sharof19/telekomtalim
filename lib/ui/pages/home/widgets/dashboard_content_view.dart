import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/data/models/main_dashboard_data.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_current_courses_card.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_mini_stat_card.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_weekly_time_card.dart';

class DashboardContentView extends StatelessWidget {
  final MainDashboardData data;
  final VoidCallback onRefresh;
  final Map<int, double> progressCache;

  const DashboardContentView({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.progressCache,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        data.progress?.overallProgressPercent ??
        _calcOverallProgress(data.currentCourses);
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              final cards = [
                DashboardMiniStatCard(
                  title: tr(context, TrKey.tugallangan),
                  value: '${data.summary.completedCoursesCount}',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.examScoreGreen,
                ),
                DashboardMiniStatCard(
                  title: tr(context, TrKey.faolKurslar),
                  value: '${data.summary.activeCoursesCount}',
                  icon: Icons.menu_book_outlined,
                  iconColor: AppColors.brandBlue,
                  onTap: () {
                    AppNavigator.pushMyCourses(context);
                  },
                ),
                DashboardMiniStatCard(
                  title: tr(context, TrKey.olinganSertifikatlar),
                  value: '0',
                  icon: Icons.workspace_premium_outlined,
                  iconColor: AppColors.accentAmber,
                  onTap: () {
                    AppNavigator.pushCertificates(context);
                  },
                ),
                DashboardMiniStatCard(
                  title: tr(context, TrKey.umumiyProgress),
                  value: '${progressPercent.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.homeStatIconPurple,
                ),
              ];
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards
                    .map((card) => SizedBox(width: cardWidth, child: card))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          DashboardWeeklyTimeCard(days: data.timeStats?.days ?? const []),
          const SizedBox(height: 12),
          DashboardCurrentCoursesCard(
            courses: data.currentCourses,
            photoByCourseId: data.coursePhotoById,
            progressCache: progressCache,
          ),
        ],
      ),
    );
  }
}

double _calcOverallProgress(List<DashboardCurrentCourse> courses) {
  if (courses.isEmpty) return 0;
  final sum = courses.fold<double>(0, (acc, course) {
    return acc + course.progressPercent;
  });
  return sum / courses.length;
}
