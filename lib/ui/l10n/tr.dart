import 'package:flutter/material.dart';

import 'tr_keys.dart';
import 'translations/auth_translations.dart';
import 'translations/common_translations.dart';
import 'translations/courses_translations.dart';
import 'translations/exams_translations.dart';
import 'translations/profile_translations.dart';
import 'translations/settings_translations.dart';

export 'tr_keys.dart';

const _translations = <TrKey, TrValue>{
  ...commonTranslations,
  ...authTranslations,
  ...coursesTranslations,
  ...examsTranslations,
  ...profileTranslations,
  ...settingsTranslations,
};

String tr(
  BuildContext context,
  TrKey key, {
  Map<String, Object?> params = const {},
}) {
  final code = Localizations.localeOf(context).languageCode;
  final entry = _translations[key];
  if (entry == null) return key.name;
  final text = code == 'ru' ? entry.ru : entry.uz;
  return _applyParams(text, params);
}

String trPair(
  BuildContext context, {
  required String uz,
  required String ru,
  Map<String, Object?> params = const {},
}) {
  final code = Localizations.localeOf(context).languageCode;
  final text = code == 'ru' ? ru : uz;
  return _applyParams(text, params);
}

String _applyParams(String template, Map<String, Object?> params) {
  var value = template;
  params.forEach((key, param) {
    value = value.replaceAll('{$key}', param?.toString() ?? '');
  });
  return value;
}
