import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_screen.dart';
import 'package:provider/provider.dart';

import '../../../../fakes/fake_counter_coordinator.dart';
import '../../../../helpers/finders.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late FakeCounterCoordinator coordinator;

  setUp(() => coordinator = FakeCounterCoordinator());

  tearDown(() => coordinator.dispose());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) => tester.pumpLocalized(
    ChangeNotifierProvider(
      create: (_) => IsolateCounterViewModel(coordinator: coordinator),
      child: const IsolateCounterScreen(),
    ),
    locale: locale,
  );

  Future<void> tapAndPump(WidgetTester tester, Key key) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  bool isLimitEnabled(WidgetTester tester) {
    final field = find.descendant(
      of: find.byKey(IsolateCounterKeys.limitInput),
      matching: find.byWidgetPredicate(
        (widget) => widget is TextField || widget is CupertinoTextField,
      ),
    );
    return switch (tester.widget(field)) {
      final TextField field => field.enabled ?? true,
      final CupertinoTextField field => field.enabled,
      final other => throw StateError('Unexpected field $other'),
    };
  }

  testWidgets('idle: shows the placeholder and only Start is enabled', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(textOf(tester, IsolateCounterKeys.value), 'Press Start');
    expect(textOf(tester, IsolateCounterKeys.status), 'Idle');
    expect(find.byKey(IsolateCounterKeys.parityBadge), findsNothing);
    expect(isButtonEnabled(tester, IsolateCounterKeys.start), isTrue);
    expect(isButtonEnabled(tester, IsolateCounterKeys.togglePause), isFalse);
    expect(isButtonEnabled(tester, IsolateCounterKeys.stop), isFalse);
  }, variant: mobilePlatforms);

  testWidgets('start: enables pause and stop and locks the limit', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapAndPump(tester, IsolateCounterKeys.start);

    expect(coordinator.lastLimit, IsolateCounterViewModel.defaultLimit);
    expect(textOf(tester, IsolateCounterKeys.status), 'Running');
    expect(isButtonEnabled(tester, IsolateCounterKeys.start), isFalse);
    expect(isButtonEnabled(tester, IsolateCounterKeys.togglePause), isTrue);
    expect(isButtonEnabled(tester, IsolateCounterKeys.stop), isTrue);
    expect(isLimitEnabled(tester), isFalse);
  }, variant: mobilePlatforms);

  testWidgets('emissions update the number and the parity badge', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tapAndPump(tester, IsolateCounterKeys.start);

    coordinator.emit(const CounterEmission(value: 1, parity: ParityEnum.odd));
    await tester.pump();
    expect(textOf(tester, IsolateCounterKeys.value), '1');
    expect(find.text('Odd isolate'), findsOneWidget);

    coordinator.emit(const CounterEmission(value: 2, parity: ParityEnum.even));
    await tester.pump();
    expect(textOf(tester, IsolateCounterKeys.value), '2');
    expect(find.text('Even isolate'), findsOneWidget);
  }, variant: mobilePlatforms);

  testWidgets('pause toggles to resume', (tester) async {
    await pumpScreen(tester);
    await tapAndPump(tester, IsolateCounterKeys.start);

    await tapAndPump(tester, IsolateCounterKeys.togglePause);

    expect(coordinator.pauseCalls, 1);
    expect(textOf(tester, IsolateCounterKeys.status), 'Paused');
    expect(find.text('Resume'), findsOneWidget);

    await tapAndPump(tester, IsolateCounterKeys.togglePause);

    expect(coordinator.resumeCalls, 1);
    expect(find.text('Pause'), findsOneWidget);
  }, variant: mobilePlatforms);

  testWidgets('stop resets the label to the placeholder', (tester) async {
    await pumpScreen(tester);
    await tapAndPump(tester, IsolateCounterKeys.start);
    coordinator.emit(const CounterEmission(value: 1, parity: ParityEnum.odd));
    await tester.pump();

    await tapAndPump(tester, IsolateCounterKeys.stop);

    expect(coordinator.stopCalls, 1);
    expect(textOf(tester, IsolateCounterKeys.value), 'Press Start');
    expect(textOf(tester, IsolateCounterKeys.status), 'Idle');
  }, variant: mobilePlatforms);

  testWidgets('reaching the limit shows finished', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byKey(IsolateCounterKeys.limitInput), '2');
    await tapAndPump(tester, IsolateCounterKeys.start);

    coordinator
      ..emit(const CounterEmission(value: 1, parity: ParityEnum.odd))
      ..emit(const CounterEmission(value: 2, parity: ParityEnum.even));
    await tester.pump();

    expect(textOf(tester, IsolateCounterKeys.status), 'Finished');
    expect(isButtonEnabled(tester, IsolateCounterKeys.start), isTrue);
  }, variant: mobilePlatforms);

  testWidgets('an out-of-range limit shows an error and disables Start', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byKey(IsolateCounterKeys.limitInput), '1');
    await tester.pump();

    expect(find.text('Enter a number from 2 to 1000'), findsOneWidget);
    expect(isButtonEnabled(tester, IsolateCounterKeys.start), isFalse);
  }, variant: mobilePlatforms);

  testWidgets('shows Portuguese strings for the pt locale', (tester) async {
    await pumpScreen(tester, locale: const Locale('pt'));

    expect(find.text('Toque em Iniciar'), findsOneWidget);
    expect(find.text('Parado'), findsOneWidget);
  }, variant: mobilePlatforms);

  testWidgets('survives a 2x text scale without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpScreen(tester);
    await tapAndPump(tester, IsolateCounterKeys.start);
    coordinator.emit(const CounterEmission(value: 999, parity: ParityEnum.odd));
    await tester.pump();

    expect(tester.takeException(), isNull);
  }, variant: mobilePlatforms);
}
