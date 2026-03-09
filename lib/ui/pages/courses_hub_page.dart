import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/darslar_page.dart';
import 'package:uztelecom/ui/pages/my_courses_page.dart';
import 'package:uztelecom/ui/pages/notifications_page.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class CoursesHubPage extends StatefulWidget {
  const CoursesHubPage({super.key});

  @override
  State<CoursesHubPage> createState() => _CoursesHubPageState();
}

class _CoursesHubPageState extends State<CoursesHubPage> {
  int _index = 0;

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConnectivityGate(child: NotificationsPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillBg = isDark ? const Color(0xFF121F2D) : const Color(0xFFEDEFF4);
    final pillBorder = isDark
        ? const Color(0xFF243447)
        : const Color(0xFFDDE1E8);
    final selectedBg = isDark ? const Color(0xFF2F80FF) : scheme.primary;
    final selectedText = Colors.white;
    final unselectedText = isDark
        ? const Color(0xFF9FB2C8)
        : scheme.onBackground.withOpacity(0.6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onBackground,
        title: Text(
          tr(context, uz: 'Kurslar', ru: 'Курсы'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: tr(context, uz: 'Xabarlar', ru: 'Уведомления'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: pillBorder),
            ),
            child: Row(
              children: [
                _SegmentButton(
                  label: tr(context, uz: 'Kurslar', ru: 'Курсы'),
                  selected: _index == 0,
                  selectedColor: selectedBg,
                  selectedText: selectedText,
                  unselectedText: unselectedText,
                  onTap: () => setState(() => _index = 0),
                ),
                _SegmentButton(
                  label: tr(context, uz: 'Mening kurslarim', ru: 'Мои курсы'),
                  selected: _index == 1,
                  selectedColor: selectedBg,
                  selectedText: selectedText,
                  unselectedText: unselectedText,
                  onTap: () => setState(() => _index = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                CoursesPage(embedded: true),
                MyCoursesPage(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color selectedText;
  final Color unselectedText;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.selectedText,
    required this.unselectedText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              color: selected ? selectedText : unselectedText,
              fontWeight: FontWeight.w700,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
