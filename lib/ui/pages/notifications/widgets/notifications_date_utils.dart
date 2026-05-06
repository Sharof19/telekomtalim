import 'package:flutter/widgets.dart';
import 'package:uztelecom/data/models/notification_item.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class NotificationGroup {
  const NotificationGroup({required this.title, required this.items});

  final String title;
  final List<NotificationItem> items;
}

List<NotificationGroup> groupNotifications(
  BuildContext context,
  List<NotificationItem> items,
) {
  final groups = <String, List<NotificationItem>>{};
  for (final item in items) {
    final title = notificationGroupTitle(context, item.createdAt);
    groups.putIfAbsent(title, () => []).add(item);
  }
  return groups.entries
      .map((entry) => NotificationGroup(title: entry.key, items: entry.value))
      .toList();
}

String notificationGroupTitle(BuildContext context, DateTime? value) {
  if (value == null) {
    return trPair(context, uz: 'AVVAL', ru: 'РАНЕЕ');
  }
  final date = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(itemDay).inDays;
  if (diff == 0) return tr(context, TrKey.bugun).toUpperCase();
  if (diff == 1) return trPair(context, uz: 'KECHA', ru: 'ВЧЕРА');
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}

String formatNotificationRelativeTime(BuildContext context, DateTime? value) {
  if (value == null) return '';
  final localeCode = Localizations.localeOf(context).languageCode;
  final diff = DateTime.now().difference(value.toLocal());
  if (diff.inMinutes < 1) {
    return localeCode == 'ru' ? 'только что' : 'hozir';
  }
  if (diff.inMinutes < 60) {
    return localeCode == 'ru'
        ? '${diff.inMinutes} мин назад'
        : '${diff.inMinutes} daq. oldin';
  }
  if (diff.inHours < 24) {
    return localeCode == 'ru'
        ? '${diff.inHours} ч назад'
        : '${diff.inHours} soat oldin';
  }
  if (diff.inDays < 7) {
    return localeCode == 'ru'
        ? '${diff.inDays} дн назад'
        : '${diff.inDays} kun oldin';
  }
  final date = value.toLocal();
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}
