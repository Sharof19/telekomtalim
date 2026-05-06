import 'package:flutter/material.dart';
import 'package:uztelecom/application/use_cases/notifications/load_notifications_use_case.dart';
import 'package:uztelecom/data/models/notification_item.dart';

enum NotificationsFilter { all, unread }

class NotificationsProvider with ChangeNotifier {
  NotificationsProvider({required LoadNotificationsUseCase loadNotifications})
    : _loadNotifications = loadNotifications;

  final LoadNotificationsUseCase _loadNotifications;
  bool _disposed = false;

  bool _isLoading = true;
  Object? _error;
  NotificationsFilter _filter = NotificationsFilter.all;
  List<NotificationItem> _allItems = const [];
  List<NotificationItem> _unreadItems = const [];

  bool get isLoading => _isLoading;
  Object? get error => _error;
  NotificationsFilter get filter => _filter;
  int get allCount => _allItems.length;
  int get unreadCount => _unreadItems.length;
  List<NotificationItem> get items =>
      _filter == NotificationsFilter.unread ? _unreadItems : _allItems;

  Future<void> load({bool force = false}) async {
    final hasData = _allItems.isNotEmpty || _unreadItems.isNotEmpty;
    if (!hasData || force) {
      _isLoading = true;
      _error = null;
      _safeNotify();
    }

    try {
      final results = await Future.wait<List<NotificationItem>>([
        _loadNotifications(),
        _loadNotifications(isRead: false),
      ]);
      _allItems = results[0];
      _unreadItems = results[1];
    } catch (error) {
      if (!hasData) _error = error;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  void setFilter(NotificationsFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    _safeNotify();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
