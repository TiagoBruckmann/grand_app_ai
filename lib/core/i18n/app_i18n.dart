import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

abstract final class AppI18n {
  static const String basePath = 'assets/i18n';

  static const List<Locale> supportedLocales = [Locale('en'), Locale('pt')];

  // `forcedLocale` lets tests pin a language regardless of the host machine.
  static List<LocalizationsDelegate<Object?>> delegates({
    Locale? forcedLocale,
  }) => [
    FlutterI18nDelegate(
      translationLoader: FileTranslationLoader(
        basePath: basePath,
        forcedLocale: forcedLocale,
      ),
    ),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
