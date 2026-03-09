import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uztelecom/ui/pages/main_page.dart';
import 'package:uztelecom/ui/pages/table_page.dart';
import 'package:uztelecom/ui/pages/profil.dart';
import 'package:uztelecom/ui/pages/courses_hub_page.dart';
import 'package:uztelecom/ui/pages/exams_page.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final PageController _pageController = PageController(
    initialPage: _currentIndex,
  );
  bool _isAnimating = false;
  int? _targetIndex;
  final GlobalKey<TablePageState> _tableKey = GlobalKey<TablePageState>();

  late final List<Widget> _pages = [
    const MainPage(key: ValueKey('main_page')),
    const CoursesHubPage(key: ValueKey('courses_hub_page')),
    TablePage(key: _tableKey),
    const ExamsPage(key: ValueKey('exams_page')),
    const ProfilePage(key: ValueKey('profile_page'), embedded: true),
  ];

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    final distance = (index - _currentIndex).abs();
    final duration = Duration(milliseconds: 220 + (distance - 1) * 160);
    _isAnimating = true;
    _targetIndex = index;
    setState(() => _currentIndex = index);
    _pageController
        .animateToPage(index, duration: duration, curve: Curves.easeInOutCubic)
        .whenComplete(() {
          if (!mounted) return;
          _isAnimating = false;
          _targetIndex = null;
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final muted = isDark
        ? const Color(0xFF9FB1C9)
        : const Color(0xFF8FA0B6);
    final navItems = [
      _NavItem(
        icon: Iconsax.element_4,
        label: tr(context, uz: 'Bosh sahifa', ru: 'Главная'),
      ),
      _NavItem(
        icon: Iconsax.book,
        label: tr(context, uz: 'Kurslar', ru: 'Курсы'),
      ),
      _NavItem(
        icon: Iconsax.video,
        label: tr(context, uz: 'Vebinarlar', ru: 'Вебинары'),
      ),
      _NavItem(
        icon: Iconsax.clipboard_text,
        label: tr(context, uz: 'Imtihonlar', ru: 'Экзамены'),
      ),
      _NavItem(
        icon: Iconsax.user,
        label: tr(context, uz: 'Profil', ru: 'Профиль'),
      ),
    ];
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomPadding = bottomInset > 0 ? bottomInset : 6.0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (_isAnimating && _targetIndex != null && index != _targetIndex) {
            return;
          }
          final prev = _currentIndex;
          setState(() => _currentIndex = index);
          if (index == 2 && prev != 2) {
            _tableKey.currentState?.refresh();
          }
        },
        physics: const PageScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF111D2A), Color(0xFF0B1724)]
                : const [Color(0xFFFFFFFF), Color(0xFFF4F6FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E2C3C) : const Color(0xFFDDE5F1),
            ),
          ),
        ),
        padding: EdgeInsets.only(top: 6, bottom: bottomPadding),
        child: Row(
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final selected = _currentIndex == index;
            return Expanded(
              child: _NavButton(
                item: item,
                selected: selected,
                isDark: isDark,
                selectedColor: primary,
                mutedColor: muted,
                onTap: () => _onNavTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final bool isDark;
  final Color selectedColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.isDark,
    required this.selectedColor,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = selected ? selectedColor : mutedColor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: isDark ? 38 : 34,
              height: isDark ? 38 : 34,
              decoration: BoxDecoration(
                color: selected
                    ? (isDark
                          ? selectedColor.withValues(alpha: 0.18)
                          : const Color(0xFFEFF4FF))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: isDark
                    ? (selected ? Colors.white : mutedColor)
                    : (selected ? selectedColor : mutedColor),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 12,
                color: labelColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
