import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

const List<ThemeMode> goldenThemes = [ThemeMode.light, ThemeMode.dark];

// Pumps [screen] on a phone-sized surface and compares it with
// `baselines/<name>.<platform>.<theme>.png`. [arrange] drives the screen into
// the state under test before the snapshot.
Future<void> expectScreenGolden(
  WidgetTester tester, {
  required String name,
  required Widget screen,
  required ThemeMode themeMode,
  Future<void> Function(WidgetTester tester)? arrange,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpLocalized(screen, themeMode: themeMode);
  await arrange?.call(tester);
  await tester.pump();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(
      'baselines/$name.${defaultTargetPlatform.name}.${themeMode.name}.png',
    ),
  );
}
