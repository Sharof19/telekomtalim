import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/core/routing/app_router.dart';
import 'package:uztelecom/core/theme/app_theme.dart';
import 'package:uztelecom/ui/providers/app/app_providers.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class UztelecomApp extends StatelessWidget {
  const UztelecomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeModeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          navigatorKey: AppRouter.navigatorKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.mode,
          locale: localeProvider.locale,
          supportedLocales: const [Locale('uz'), Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) {
            return ConnectivityGate(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}
