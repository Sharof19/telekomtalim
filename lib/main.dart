import 'package:flutter/material.dart';
import 'package:uztelecom/app/app_bootstrap.dart';
import 'package:uztelecom/app/app_provider_scope.dart';
import 'package:uztelecom/app/uztelecom_app.dart';

Future<void> main() async {
  final bootstrap = await AppBootstrap.initialize();

  runApp(
    AppProviderScope(
      services: bootstrap.services,
      themeProvider: bootstrap.themeProvider,
      localeProvider: bootstrap.localeProvider,
      child: const UztelecomApp(),
    ),
  );
}
