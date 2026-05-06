import 'package:flutter_test/flutter_test.dart';
import 'package:uztelecom/data/models/notification_item.dart';

void main() {
  test('parses notification i18n fields and cleans html body', () {
    final item = NotificationItem.fromJson({
      'id': 197187,
      'category': {
        'code': 'auth_security_alert',
        'label': {
          'uz': 'Xavfsizlik ogohlantirishi',
          'ru': 'Оповещение безопасности',
          'en': 'Security alert',
        },
      },
      'title': 'Yangi kirish aniqlandi',
      'body': 'Tizimga kirish<br>IP: 192.168.60.10',
      'data': {
        'i18n': {
          'title': {
            'uz': 'Yangi kirish aniqlandi',
            'ru': 'Обнаружен новый вход',
          },
          'body': {
            'uz': 'Tizimga kirish vaqti<br>IP manzil: 192.168.60.10.',
            'ru': 'Время входа<br>IP-адрес: 192.168.60.10.',
          },
        },
      },
      'is_read': false,
      'created_at': '2026-05-05T10:55:18.705693Z',
    });

    expect(item.id, 197187);
    expect(item.isRead, isFalse);
    expect(item.category.code, 'auth_security_alert');
    expect(item.category.labelFor('uz'), 'Xavfsizlik ogohlantirishi');
    expect(item.titleFor('uz'), 'Yangi kirish aniqlandi');
    expect(item.titleFor('ru'), 'Обнаружен новый вход');
    expect(
      item.bodyFor('uz'),
      'Tizimga kirish vaqti\nIP manzil: 192.168.60.10.',
    );
    expect(item.createdAt, isNotNull);
  });

  test('falls back to plain body and removes paragraph entities', () {
    final item = NotificationItem.fromJson({
      'id': 193524,
      'category': {
        'code': 'system_announcement',
        'label': {'uz': "Tizim e'loni"},
      },
      'title': 'Test',
      'body': '<p>Lorem&nbsp;ipsum&nbsp;&amp;&nbsp;test.</p>',
      'is_read': true,
    });

    expect(item.isRead, isTrue);
    expect(item.bodyFor('uz'), 'Lorem ipsum & test.');
  });
}
