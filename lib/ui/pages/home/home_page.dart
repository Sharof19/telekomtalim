import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uztelecom/ui/pages/home/main_page.dart';
import 'package:uztelecom/ui/pages/home/widgets/home_bottom_nav_bar.dart';
import 'package:uztelecom/ui/pages/schedule/webinars_page.dart';
import 'package:uztelecom/ui/pages/profile/profile_page.dart';
import 'package:uztelecom/ui/pages/courses/courses_hub_page.dart';
import 'package:uztelecom/ui/pages/exams/exams_page.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<WebinarsPageState> _tableKey = GlobalKey<WebinarsPageState>();

  late final List<Widget> _pages = [
    const MainPage(key: ValueKey('main_page')),
    const CoursesHubPage(key: ValueKey('courses_hub_page')),
    WebinarsPage(key: _tableKey),
    const ExamsPage(key: ValueKey('exams_page')),
    const ProfilePage(key: ValueKey('profile_page'), embedded: true),
  ];

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    final prev = _currentIndex;
    setState(() => _currentIndex = index);
    if (index == 2 && prev != 2) {
      _tableKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      HomeNavItem(icon: Iconsax.element_4, label: tr(context, TrKey.home)),
      HomeNavItem(icon: Iconsax.book, label: tr(context, TrKey.courses)),
      HomeNavItem(icon: Iconsax.video, label: tr(context, TrKey.webinars)),
      HomeNavItem(
        icon: Iconsax.clipboard_text,
        label: tr(context, TrKey.exams),
      ),
      HomeNavItem(icon: Iconsax.user, label: tr(context, TrKey.profile)),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        items: navItems,
        onTap: _onNavTap,
      ),
    );
  }
}
