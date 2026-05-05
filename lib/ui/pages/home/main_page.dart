import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/facades/dashboard_facade.dart';
import 'package:uztelecom/data/models/dashboard_models.dart';
import 'package:uztelecom/ui/providers/home/main_page_provider.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_app_bar_content.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_content_view.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_error_card.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/app_shimmer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  late final MainPageProvider _provider;
  bool _offlinePushed = false;
  final Map<int, double> _progressCache = {};

  @override
  void initState() {
    super.initState();
    _provider = MainPageProvider(
      dashboardFacade: context.read<DashboardFacade>(),
    )..load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _syncProgressCache(List<DashboardCurrentCourse> courses) {
    final ids = <int>{};
    for (final course in courses) {
      ids.add(course.courseId);
      _progressCache[course.courseId] = course.progressPercent;
    }
    _progressCache.removeWhere((key, _) => !ids.contains(key));
  }

  void _reload() {
    _provider.load();
  }

  void _showOfflinePage() {
    if (_offlinePushed) return;
    _offlinePushed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppNavigator.pushNoInternetPage<void>(
        context,
        onRetry: () {
          Navigator.of(context).pop();
          _offlinePushed = false;
          _reload();
        },
      ).then((_) {
        _offlinePushed = false;
      });
    });
  }

  void _onNotificationsTap() {
    AppNavigator.pushNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final onBg = Theme.of(context).colorScheme.onSurface;

    return ChangeNotifierProvider<MainPageProvider>.value(
      value: _provider,
      child: Consumer<MainPageProvider>(
        builder: (context, provider, _) {
          final error = provider.error;
          if (error != null && isNoInternetError(error)) {
            _showOfflinePage();
          }
          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              elevation: 0,
              foregroundColor: onBg,
              toolbarHeight: 86,
              titleSpacing: 14,
              title: DashboardAppBarContent(fallbackName: provider.appBarName),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    onPressed: _onNotificationsTap,
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: tr(context, TrKey.notifications),
                  ),
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
                final data = provider.data;
                if (provider.isLoading && data == null) {
                  return const DashboardSkeleton();
                }
                if (error != null && data == null) {
                  if (isNoInternetError(error)) {
                    return const SizedBox.shrink();
                  }
                  return DashboardErrorCard(
                    message: tr(
                      context,
                      TrKey.dashboardMalumotlariniYuklabBolmadi,
                    ),
                    onRetry: _reload,
                  );
                }
                if (data == null) {
                  return DashboardErrorCard(
                    message: tr(context, TrKey.dashboardMalumotlariTopilmadi),
                    onRetry: _reload,
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _syncProgressCache(data.currentCourses);
                });
                return DashboardContentView(
                  data: data,
                  onRefresh: _reload,
                  progressCache: _progressCache,
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
