import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/notifications/load_notifications_use_case.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/notifications/widgets/notifications_body.dart';
import 'package:uztelecom/ui/providers/notifications/notifications_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NotificationsProvider(
      loadNotifications: context.read<LoadNotificationsUseCase>(),
    )..load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final scheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<NotificationsProvider>.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: scheme.onSurface,
          titleSpacing: 18,
          title: Text(
            trPair(context, uz: 'Bildirishnomalar', ru: 'Уведомления'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: const NotificationsBody(),
      ),
    );
  }
}
