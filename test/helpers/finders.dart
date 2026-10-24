import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Whether the adaptive button under [key] is enabled, on either platform.
bool isButtonEnabled(WidgetTester tester, Key key) {
  final button = find.descendant(
    of: find.byKey(key),
    matching: find.byWidgetPredicate(
      (widget) => widget is ButtonStyleButton || widget is CupertinoButton,
    ),
  );
  return switch (tester.widget(button)) {
    final ButtonStyleButton button => button.enabled,
    final CupertinoButton button => button.enabled,
    final other => throw StateError('Unexpected button $other'),
  };
}

String textOf(WidgetTester tester, Key key) =>
    tester.widget<Text>(find.byKey(key)).data ?? '';
