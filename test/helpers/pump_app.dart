import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/core/i18n/app_i18n.dart';
import 'package:grand_app_ia_challange1/core/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  // Wraps [child] with the app theme and i18n delegates. flutter_i18n loads
  // its JSON asynchronously, hence the settle before returning.
  Future<void> pumpLocalized(
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppI18n.supportedLocales,
        localizationsDelegates: AppI18n.delegates(forcedLocale: locale),
        home: child,
      ),
    );
    await pumpAndSettle();
  }
}

const TargetPlatformVariant mobilePlatforms = TargetPlatformVariant({
  TargetPlatform.android,
  TargetPlatform.iOS,
});
