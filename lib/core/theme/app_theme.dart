import 'package:flutter/material.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';

abstract final class AppTheme {
  static const Color _seed = Colors.indigo;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  // `platform` is intentionally left null so the theme follows the device
  // and `TargetPlatformVariant` can override it in tests.
  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
