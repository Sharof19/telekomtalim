import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class HomeNavItem {
  final IconData icon;
  final String label;

  const HomeNavItem({required this.icon, required this.label});
}

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<HomeNavItem> items;
  final ValueChanged<int> onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final muted = isDark
        ? AppColors.homeNavMutedDark
        : AppColors.homeNavMutedLight;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomPadding = bottomInset > 0 ? bottomInset : 6.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  AppColors.homeNavGradientDarkStart,
                  AppColors.darkBackground,
                ]
              : const [AppColors.white, AppColors.homeNavGradientLightEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.homeNavBorderLight,
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 6, bottom: bottomPadding),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: _HomeNavButton(
              item: item,
              selected: currentIndex == index,
              isDark: isDark,
              selectedColor: primary,
              mutedColor: muted,
              onTap: () => onTap(index),
            ),
          );
        }),
      ),
    );
  }
}

class _HomeNavButton extends StatelessWidget {
  final HomeNavItem item;
  final bool selected;
  final bool isDark;
  final Color selectedColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _HomeNavButton({
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
                          : AppColors.homeNavSelectedLight)
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: isDark
                    ? (selected ? AppColors.white : mutedColor)
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
