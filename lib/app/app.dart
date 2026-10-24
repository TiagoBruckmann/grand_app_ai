import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_app_ia_challange1/app/router.dart';
import 'package:grand_app_ia_challange1/core/i18n/app_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({this.locale, super.key});

  final Locale? locale;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createRouter();
  late final List<LocalizationsDelegate<Object?>> _delegates =
      AppI18n.delegates(forcedLocale: widget.locale);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) =>
          FlutterI18n.translate(context, I18nKeys.appTitle),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: widget.locale,
      supportedLocales: AppI18n.supportedLocales,
      localizationsDelegates: _delegates,
      routerConfig: _router,
    );
  }
}
