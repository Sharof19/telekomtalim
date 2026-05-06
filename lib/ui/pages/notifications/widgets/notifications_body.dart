import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/notifications/widgets/notifications_filter_switch.dart';
import 'package:uztelecom/ui/pages/notifications/widgets/notifications_list.dart';
import 'package:uztelecom/ui/providers/notifications/notifications_provider.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        final hasData = provider.allCount > 0 || provider.unreadCount > 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Text(
                _subtitle(context, provider.unreadCount),
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.52),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: NotificationsFilterSwitch(provider: provider),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.load(force: true),
                child: NotificationsList(provider: provider, hasData: hasData),
              ),
            ),
          ],
        );
      },
    );
  }

  String _subtitle(BuildContext context, int unreadCount) {
    if (unreadCount == 0) {
      return trPair(
        context,
        uz: "Yangi xabar yo'q",
        ru: 'Новых уведомлений нет',
      );
    }
    return trPair(
      context,
      uz: '$unreadCount ta yangi xabar',
      ru: '$unreadCount новых уведомлений',
    );
  }
}
