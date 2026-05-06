import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/providers/notifications/notifications_provider.dart';

class NotificationsFilterSwitch extends StatelessWidget {
  const NotificationsFilterSwitch({super.key, required this.provider});

  final NotificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterPill(
              label: trPair(context, uz: 'Barchasi', ru: 'Все'),
              count: provider.allCount,
              selected: provider.filter == NotificationsFilter.all,
              onTap: () => provider.setFilter(NotificationsFilter.all),
            ),
          ),
          Expanded(
            child: _FilterPill(
              label: trPair(context, uz: "O'qilmagan", ru: 'Непрочитанные'),
              count: provider.unreadCount,
              selected: provider.filter == NotificationsFilter.unread,
              onTap: () => provider.setFilter(NotificationsFilter.unread),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = selected
        ? AppColors.white
        : isDark
        ? AppColors.darkMuted
        : const Color(0xFF687082);
    return Material(
      color: selected ? const Color(0xFF1293E8) : AppColors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.white.withValues(alpha: 0.22)
                        : const Color(0xFFE1E6EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? AppColors.white : textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
