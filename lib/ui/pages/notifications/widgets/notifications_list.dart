import 'package:flutter/material.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/notifications/widgets/notification_tile.dart';
import 'package:uztelecom/ui/pages/notifications/widgets/notifications_date_utils.dart';
import 'package:uztelecom/ui/providers/notifications/notifications_provider.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    super.key,
    required this.provider,
    required this.hasData,
  });

  final NotificationsProvider provider;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && !hasData) {
      return const _LoadingList();
    }
    if (provider.error != null && !hasData) {
      return _MessageList(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        message: appFailureMessage(provider.error!),
      );
    }
    if (provider.items.isEmpty) {
      return _MessageList(
        icon: Icons.notifications_none_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        message: provider.filter == NotificationsFilter.unread
            ? trPair(
                context,
                uz: "O'qilmagan xabar yo'q.",
                ru: 'Непрочитанных уведомлений нет.',
              )
            : tr(context, TrKey.sizdaXabarlarMavjudEmas),
      );
    }

    final groups = groupNotifications(context, provider.items);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) =>
          _NotificationGroupSection(group: groups[index], isFirst: index == 0),
    );
  }
}

class _NotificationGroupSection extends StatelessWidget {
  const _NotificationGroupSection({required this.group, required this.isFirst});

  final NotificationGroup group;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.48);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, isFirst ? 8 : 22, 12, 12),
          child: Text(
            group.title,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        for (final item in group.items) NotificationTile(item: item),
      ],
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 140),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 54, color: iconColor),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
