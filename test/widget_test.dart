import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uztelecom/app/app_provider_scope.dart';
import 'package:uztelecom/app/app_services.dart';
import 'package:uztelecom/app/uztelecom_app.dart';
import 'package:uztelecom/ui/providers/app/locale_provider.dart';
import 'package:uztelecom/ui/providers/app/theme_mode_provider.dart';

void main() {
  testWidgets('UztelecomApp builds', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const {});

    await tester.pumpWidget(
      AppProviderScope(
        services: AppServices(),
        themeProvider: ThemeModeProvider(),
        localeProvider: LocaleProvider(),
        child: const UztelecomApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
