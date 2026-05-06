class NotificationCategory {
  const NotificationCategory({
    required this.code,
    required this.labelUz,
    required this.labelRu,
    required this.labelEn,
  });

  final String? code;
  final String? labelUz;
  final String? labelRu;
  final String? labelEn;

  String labelFor(String localeCode) {
    final value = switch (localeCode) {
      'ru' => labelRu,
      'en' => labelEn,
      _ => labelUz,
    };
    return _firstNonEmpty(value, labelUz, labelRu, labelEn) ?? '';
  }

  factory NotificationCategory.fromJson(Object? value) {
    if (value is! Map) {
      return const NotificationCategory(
        code: null,
        labelUz: null,
        labelRu: null,
        labelEn: null,
      );
    }
    final map = Map<String, dynamic>.from(value);
    final label = map['label'];
    final labelMap = label is Map ? Map<String, dynamic>.from(label) : null;
    return NotificationCategory(
      code: map['code']?.toString(),
      labelUz: labelMap?['uz']?.toString(),
      labelRu: labelMap?['ru']?.toString(),
      labelEn: labelMap?['en']?.toString(),
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.titleUz,
    required this.titleRu,
    required this.titleEn,
    required this.bodyUz,
    required this.bodyRu,
    required this.bodyEn,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
    required this.sourceType,
  });

  final int id;
  final NotificationCategory category;
  final String? title;
  final String? body;
  final String? titleUz;
  final String? titleRu;
  final String? titleEn;
  final String? bodyUz;
  final String? bodyRu;
  final String? bodyEn;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String? sourceType;

  String titleFor(String localeCode) {
    final value = switch (localeCode) {
      'ru' => titleRu,
      'en' => titleEn,
      _ => titleUz,
    };
    return _cleanText(
          _firstNonEmpty(value, title, titleUz, titleRu, titleEn),
        ) ??
        '';
  }

  String bodyFor(String localeCode) {
    final value = switch (localeCode) {
      'ru' => bodyRu,
      'en' => bodyEn,
      _ => bodyUz,
    };
    return _cleanText(_firstNonEmpty(value, body, bodyUz, bodyRu, bodyEn)) ??
        '';
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final i18n = dataMap?['i18n'];
    final i18nMap = i18n is Map ? Map<String, dynamic>.from(i18n) : null;
    final title = i18nMap?['title'];
    final titleMap = title is Map ? Map<String, dynamic>.from(title) : null;
    final body = i18nMap?['body'];
    final bodyMap = body is Map ? Map<String, dynamic>.from(body) : null;

    return NotificationItem(
      id: _pickInt(json['id']) ?? 0,
      category: NotificationCategory.fromJson(json['category']),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      titleUz: titleMap?['uz']?.toString(),
      titleRu: titleMap?['ru']?.toString(),
      titleEn: titleMap?['en']?.toString(),
      bodyUz: bodyMap?['uz']?.toString(),
      bodyRu: bodyMap?['ru']?.toString(),
      bodyEn: bodyMap?['en']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']),
      readAt: _parseDate(json['read_at']),
      sourceType: json['source_type']?.toString(),
    );
  }

  static int? _pickInt(Object? value) {
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

String? _firstNonEmpty(
  String? first, [
  String? second,
  String? third,
  String? fourth,
  String? fifth,
]) {
  for (final value in [first, second, third, fourth, fifth]) {
    if (value != null && value.trim().isNotEmpty) return value;
  }
  return null;
}

String? _cleanText(String? value) {
  if (value == null) return null;
  var text = value
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</\s*p\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\s*\n\s*'), '\n')
      .trim();
  return text.isEmpty ? null : text;
}
