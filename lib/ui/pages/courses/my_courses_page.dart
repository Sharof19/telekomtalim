import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/courses/load_my_courses_use_case.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/data/models/my_course_item.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_empty_state.dart';
import 'package:uztelecom/ui/pages/courses/widgets/my_course_card.dart';
import 'package:uztelecom/ui/utils/network_error.dart';
import 'package:uztelecom/ui/widgets/app_shimmer.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late final LoadMyCoursesUseCase _loadMyCourses;
  late Future<List<MyCourseItem>> _future;
  bool _offlinePushed = false;

  @override
  void initState() {
    super.initState();
    _loadMyCourses = context.read<LoadMyCoursesUseCase>();
    _future = _loadMyCourses();
  }

  void _reload() {
    setState(() {
      _future = _loadMyCourses();
    });
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final body = _MyCoursesBody(
      future: _future,
      onOfflineDetected: _showOfflinePage,
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
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        title: Text(
          tr(context, TrKey.myCourses),
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

class _MyCoursesBody extends StatelessWidget {
  const _MyCoursesBody({required this.future, required this.onOfflineDetected});

  final Future<List<MyCourseItem>> future;
  final VoidCallback onOfflineDetected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: FutureBuilder<List<MyCourseItem>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListCardsSkeleton(itemCount: 4, imageWidth: 110);
          }

          if (snapshot.hasError) {
            final error = snapshot.error!;
            if (isNoInternetError(error)) {
              onOfflineDetected();
              return const SizedBox.shrink();
            }
            return CourseEmptyState(
              message: tr(context, TrKey.kurslarniYuklashdaXatolikQaytaUrinib),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return CourseEmptyState(
              message: tr(context, TrKey.kurslarHozirchaMavjudEmas),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => MyCourseCard(item: items[index]),
          );
        },
      ),
    );
  }
}
