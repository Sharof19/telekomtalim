import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uztelecom/app/app_services.dart';
import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/data/datasources/local/cache_local_data_source.dart';
import 'package:uztelecom/ui/providers/app/app_providers.dart';

class AppBootstrapData {
  final AppServices services;
  final ThemeModeProvider themeProvider;
  final LocaleProvider localeProvider;

  const AppBootstrapData({
    required this.services,
    required this.themeProvider,
    required this.localeProvider,
  });
}

class AppBootstrap {
  static Future<AppBootstrapData> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppConfig.load();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: AppColors.black),
    );

    final themeProvider = ThemeModeProvider();
    await themeProvider.loadThemeMode();

    final localeProvider = LocaleProvider();
    await localeProvider.loadLocale();

    await CacheLocalDataSource.maintainOnStartup();
    final services = AppServices();

    return AppBootstrapData(
      services: services,
      themeProvider: themeProvider,
      localeProvider: localeProvider,
    );
  }
}
