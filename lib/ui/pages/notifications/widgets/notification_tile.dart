import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/models/notification_item.dart';
import 'package:uztelecom/ui/pages/notifications/widgets/notifications_date_utils.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final category = item.category.labelFor(localeCode);
    final isSecurity = item.category.code == 'auth_security_alert';
    final meta = [
      formatNotificationRelativeTime(context, item.createdAt),
      if (category.isNotEmpty) category,
    ].where((value) => value.isNotEmpty).join(' - ');

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationIcon(isSecurity: isSecurity),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 8, 12, 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: _NotificationText(item: item, meta: meta),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.isSecurity});

  final bool isSecurity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isSecurity
            ? const Color(0xFFFFE1E4)
            : scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        isSecurity ? Icons.shield_outlined : Icons.info_outline_rounded,
        color: isSecurity ? const Color(0xFFFF3045) : AppColors.mutedGray,
        size: 24,
      ),
    );
  }
}

class _NotificationText extends StatelessWidget {
  const _NotificationText({required this.item, required this.meta});

  final NotificationItem item;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final titleColor = item.isRead ? const Color(0xFF8BA0BD) : scheme.onSurface;
    final bodyColor = item.isRead
        ? const Color(0xFF536B8C)
        : scheme.onSurface.withValues(alpha: 0.78);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.titleFor(localeCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                ),
              ),
            ),
            if (!item.isRead) const _UnreadDot(),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          item.bodyFor(localeCode),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: bodyColor,
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.32),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF1293E8),
        shape: BoxShape.circle,
      ),
    );
  }
}
