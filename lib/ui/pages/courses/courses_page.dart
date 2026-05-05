import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/courses/load_courses_use_case.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_card.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_empty_state.dart';
import 'package:uztelecom/ui/providers/courses/courses_provider.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/app_shimmer.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late final CoursesProvider _provider;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _provider = CoursesProvider(loadCourses: context.read<LoadCoursesUseCase>())
      ..load();
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

  void _openNotifications() {
    AppNavigator.pushNotifications(context);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final body = ChangeNotifierProvider<CoursesProvider>.value(
      value: _provider,
      child: const _CoursesBody(),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: scheme.onSurface,
        title: Text(
          tr(context, TrKey.courses),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, TrKey.notifications),
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _CoursesBody extends StatelessWidget {
  const _CoursesBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Consumer<CoursesProvider>(
        builder: (context, provider, _) {
          final state = context.findAncestorStateOfType<_CoursesPageState>();
          final error = provider.error;

          if (provider.isLoading) {
            return const ListCardsSkeleton(itemCount: 4, imageWidth: 110);
          }

          if (error != null) {
            if (isNoInternetError(error)) {
              state?._showOfflinePage();
              return const SizedBox.shrink();
            }
            return CourseEmptyState(
              message: tr(context, TrKey.kurslarniYuklashdaXatolikQaytaUrinib),
            );
          }

          final items = provider.items;
          if (items.isEmpty) {
            return CourseEmptyState(
              message: tr(context, TrKey.kurslarHozirchaMavjudEmas),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => CourseCard(item: items[index]),
          );
        },
      ),
    );
  }
}
