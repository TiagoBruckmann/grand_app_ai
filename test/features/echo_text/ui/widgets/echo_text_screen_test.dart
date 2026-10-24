import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/view_model/echo_text_view_model.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_keys.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_screen.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/finders.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) => tester.pumpLocalized(
    ChangeNotifierProvider(
      create: (_) => EchoTextViewModel(),
      child: const EchoTextScreen(),
    ),
    locale: locale,
  );

  bool isSubmitEnabled(WidgetTester tester) =>
      isButtonEnabled(tester, EchoTextKeys.submit);

  String labelText(WidgetTester tester) => textOf(tester, EchoTextKeys.label);

  testWidgets('shows the placeholder and a disabled button initially', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(labelText(tester), 'Your text will appear here');
    expect(isSubmitEnabled(tester), isFalse);
  }, variant: mobilePlatforms);

  testWidgets('keeps the button disabled for whitespace-only input', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byKey(EchoTextKeys.input), '   ');
    await tester.pump();

    expect(isSubmitEnabled(tester), isFalse);
  }, variant: mobilePlatforms);

  testWidgets('tapping submit echoes the trimmed text and clears the input', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byKey(EchoTextKeys.input), '  Hello  ');
    await tester.pump();
    expect(isSubmitEnabled(tester), isTrue);

    await tester.tap(find.byKey(EchoTextKeys.submit));
    await tester.pump();

    expect(labelText(tester), 'Hello');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );
    expect(isSubmitEnabled(tester), isFalse);
  }, variant: mobilePlatforms);

  testWidgets('pressing done on the keyboard submits', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byKey(EchoTextKeys.input), 'Keyboard');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(labelText(tester), 'Keyboard');
  }, variant: mobilePlatforms);

  testWidgets('pressing done with blank input changes nothing', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byKey(EchoTextKeys.input), '  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(labelText(tester), 'Your text will appear here');
  }, variant: mobilePlatforms);

  testWidgets('a new submit replaces the label', (tester) async {
    await pumpScreen(tester);

    for (final text in ['first', 'second']) {
      await tester.enterText(find.byKey(EchoTextKeys.input), text);
      await tester.pump();
      await tester.tap(find.byKey(EchoTextKeys.submit));
      await tester.pump();
    }

    expect(labelText(tester), 'second');
  }, variant: mobilePlatforms);

  testWidgets('shows Portuguese strings for the pt locale', (tester) async {
    await pumpScreen(tester, locale: const Locale('pt'));

    expect(find.text('Seu texto aparecerá aqui'), findsOneWidget);
    expect(find.text('Mostrar texto'), findsOneWidget);
  }, variant: mobilePlatforms);

  testWidgets('long text wraps without overflow at 2x text scale', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(EchoTextKeys.input),
      List.filled(30, 'word').join(' '),
    );
    await tester.pump();
    await tester.tap(find.byKey(EchoTextKeys.submit));
    await tester.pump();

    expect(tester.takeException(), isNull);
  }, variant: mobilePlatforms);
}
