class CourseModelParser {
  const CourseModelParser._();

  static Map<String, dynamic> flattenEduResources(Map<String, dynamic> json) {
    final source = Map<String, dynamic>.from(json);
    final rootId = source['id'];
    final nested = source['edu_resources'];
    if (nested is Map<String, dynamic>) {
      final nestedMap = Map<String, dynamic>.from(nested);
      source.addAll(nestedMap);
      if (rootId != null) {
        source['id'] = rootId;
        source['course_item_id'] = rootId;
      }
      if (nestedMap['id'] != null) {
        source['edu_resource_id'] = nestedMap['id'];
      }
    }
    return source;
  }

  static String? pickLocalizedValue(
    Map<String, dynamic>? map,
    String base,
    String localeCode,
  ) {
    if (map == null) return null;
    return map['${base}_$localeCode']?.toString() ?? map[base]?.toString();
  }

  static Map<String, dynamic> pickDisplayMap(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = map[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return <String, dynamic>{};
  }

  static String? pickFirstDisplayText(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is List && value.isNotEmpty) {
      final first = value.first?.toString();
      if (first != null && first.trim().isNotEmpty) return first;
    }
    return null;
  }

  static String? forLocale(String localeCode, String? uz, String? ru) {
    final primary = localeCode == 'ru' ? ru : uz;
    final secondary = localeCode == 'ru' ? uz : ru;
    return firstNonEmpty(primary, secondary);
  }

  static String? firstNonEmpty(
    String? first, [
    String? second,
    String? third,
    String? fourth,
  ]) {
    for (final value in [first, second, third, fourth]) {
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static String? pickMediaPath(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = _stringFromMediaValue(json[key]);
      if (value != null) return value;
    }
    return _findMediaPathDeep(
      json,
      keys.map((entry) => entry.toLowerCase()).toSet(),
    );
  }

  static int? pickInt(Object? value) {
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? pickDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static String? _stringFromMediaValue(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      const nestedKeys = [
        'url',
        'file',
        'path',
        'src',
        'href',
        'absolute_url',
        'download_url',
      ];
      for (final key in nestedKeys) {
        final nested = _stringFromMediaValue(map[key]);
        if (nested != null) return nested;
      }
    }
    if (value is List) {
      for (final item in value) {
        final nested = _stringFromMediaValue(item);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static String? _findMediaPathDeep(Object? value, Set<String> wantedKeys) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        if (wantedKeys.contains(entry.key.toLowerCase())) {
          final direct = _stringFromMediaValue(entry.value);
          if (direct != null) return direct;
        }
        final nested = _findMediaPathDeep(entry.value, wantedKeys);
        if (nested != null) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _findMediaPathDeep(item, wantedKeys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static String? pickTrainerName(Map<String, dynamic> map) {
    final trainers = map['trainers'];
    if (trainers is List && trainers.isNotEmpty) {
      final first = trainers.first;
      if (first is Map) {
        final trainer = Map<String, dynamic>.from(first);
        final direct = trainer['full_name']?.toString();
        if (direct != null && direct.isNotEmpty) return direct;
        final employee = trainer['employee_display'];
        if (employee is Map) {
          final employeeMap = Map<String, dynamic>.from(employee);
          final fullName = employeeMap['full_name']?.toString();
          if (fullName != null && fullName.isNotEmpty) return fullName;
        }
      }
    }
    return null;
  }

  static String? pickLaunchUrl(Map<String, dynamic> json) {
    const directKeys = [
      'launch_url',
      'scorm_launch_url',
      'scorm_url',
      'content_url',
      'resource_url',
      'viewer_url',
      'open_url',
      'index_api_url',
      'index_url',
      'url',
      'href',
      'link',
    ];

    for (final key in directKeys) {
      final value = json[key]?.toString();
      if (_looksLikeLaunchUrl(value)) return value;
    }

    const nestedKeys = [
      'scorm',
      'xapi',
      'launch',
      'resource',
      'content',
      'player',
      'links',
    ];
    for (final key in nestedKeys) {
      final nested = json[key];
      if (nested is Map<String, dynamic>) {
        final nestedUrl = pickLaunchUrl(nested);
        if (nestedUrl != null) return nestedUrl;
      }
    }

    return _findLaunchUrlDeep(json);
  }

  static String? pickFullQuery(Map<String, dynamic> json) {
    final direct = _pickStringByKeysDeep(json, const [
      'full_query',
      'query',
      'launch_query',
      'scorm_query',
      'xapi_query',
    ]);
    if (_looksLikeFullQuery(direct)) return direct;
    return _findFullQueryDeep(json);
  }

  static String? _findLaunchUrlDeep(Object? value) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final found = _findLaunchUrlDeep(entry.value);
        if (found != null) return found;
      }
      return null;
    }
    if (value is List) {
      for (final item in value) {
        final found = _findLaunchUrlDeep(item);
        if (found != null) return found;
      }
      return null;
    }
    if (value is String && _looksLikeLaunchUrl(value)) {
      return value;
    }
    return null;
  }

  static bool _looksLikeLaunchUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (!(lower.startsWith('http://') || lower.startsWith('https://'))) {
      return false;
    }
    return lower.contains('/scormdriver/indexapi.html') ||
        lower.contains('lrs.uztelecom.uz') ||
        lower.contains('auth=bearer%20') ||
        (lower.contains('registration=') && lower.contains('actor='));
  }

  static String? _pickStringByKeysDeep(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return _findStringByKeysDeep(
      json,
      keys.map((entry) => entry.toLowerCase()).toSet(),
    );
  }

  static String? _findStringByKeysDeep(Object? value, Set<String> wantedKeys) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        if (wantedKeys.contains(entry.key.toLowerCase())) {
          final text = entry.value?.toString();
          if (text != null && text.isNotEmpty) return text;
        }
        final nested = _findStringByKeysDeep(entry.value, wantedKeys);
        if (nested != null) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _findStringByKeysDeep(item, wantedKeys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static String? _findFullQueryDeep(Object? value) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final direct = entry.value?.toString();
        if (_looksLikeFullQuery(direct)) return direct;
        final nested = _findFullQueryDeep(entry.value);
        if (nested != null) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _findFullQueryDeep(item);
        if (nested != null) return nested;
      }
    } else if (value is String && _looksLikeFullQuery(value)) {
      return value;
    }
    return null;
  }

  static bool _looksLikeFullQuery(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return false;
    }
    return lower.contains('endpoint=') &&
        lower.contains('registration=') &&
        lower.contains('actor=');
  }
}
