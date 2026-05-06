import 'dart:convert';

import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/notification_item.dart';

class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NotificationItem>> fetchNotifications({bool? isRead}) async {
    final items = <NotificationItem>[];
    Uri? nextUrl = AppEndpoints.notifications(isRead: isRead);
    var safety = 0;

    while (nextUrl != null && safety < 10) {
      final response = await _apiClient.get(nextUrl, authorized: true);
      ApiClient.ensureSuccess(
        response,
        fallbackMessage: 'Bildirishnomalarni olishda xatolik.',
      );

      final body = ApiClient.decodeObjectBody(response.body);
      ApiClient.ensureBodyStatusOk(
        body,
        fallbackMessage: 'Bildirishnomalarni olishda xatolik.',
      );
      final data = ApiClient.dataList(body);
      items.addAll(
        data.whereType<Map<String, dynamic>>().map(NotificationItem.fromJson),
      );
      nextUrl = ApiClient.extractNextPageUri(body);
      safety += 1;
    }

    return items;
  }

  Future<void> registerDevice({
    required String platform,
    required String pushToken,
    String clientType = 'mobile',
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.registerNotificationDevice(),
      authorized: true,
      headers: ApiClient.defaultJsonHeaders,
      body: jsonEncode({
        'platform': platform,
        'push_token': pushToken,
        'client_type': clientType,
      }),
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Qurilmani bildirishnomalarga ulashda xatolik.',
    );
  }
}
