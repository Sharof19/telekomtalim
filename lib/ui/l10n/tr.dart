import 'package:flutter/material.dart';

String tr(
  BuildContext context, {
  required String uz,
  required String ru,
}) {
  final code = Localizations.localeOf(context).languageCode;
  return code == 'ru' ? ru : uz;
}
