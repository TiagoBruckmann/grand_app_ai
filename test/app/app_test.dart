import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/app/app.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_keys.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_screen.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_coordinator.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_screen.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_counter_coordinator.dart';
import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeCounterCoordinator coordinator;

  setUp(() => coordinator = FakeCounterCoordinator());

  tearDown(() => coordinator.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<CounterCoordinator>.value(
        value: coordinator,
        child: const App(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the echo text tab', (tester) async {
    await pumpApp(tester);

    expect(find.byType(EchoTextScreen), findsOneWidget);
  }, variant: mobilePlatforms);

  testWidgets('switching tabs keeps each feature state', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byKey(EchoTextKeys.input), 'kept');
    await tester.pump();
    await tester.tap(find.byKey(EchoTextKeys.submit));
    await tester.pump();

    await tester.tap(find.text('Isolates'));
    await tester.pumpAndSettle();
    expect(find.byType(IsolateCounterScreen), findsOneWidget);

    await tester.tap(find.text('Echo'));
    await tester.pumpAndSettle();
    expect(textOf(tester, EchoTextKeys.label), 'kept');
  }, variant: mobilePlatforms);
}
