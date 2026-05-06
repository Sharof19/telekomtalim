import 'package:uztelecom/data/models/notification_item.dart';
import 'package:uztelecom/data/repositories/notifications_repository.dart';

class LoadNotificationsUseCase {
  const LoadNotificationsUseCase({
    required NotificationsRepository notificationsRepository,
  }) : _notificationsRepository = notificationsRepository;

  final NotificationsRepository _notificationsRepository;

  Future<List<NotificationItem>> call({bool? isRead}) {
    return _notificationsRepository.fetchNotifications(isRead: isRead);
  }
}
