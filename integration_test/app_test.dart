import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/app/app.dart';
import 'package:grand_app_ia_challange1/app/dependencies.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_keys.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String textOf(WidgetTester tester, Key key) =>
      tester.widget<Text>(find.byKey(key)).data ?? '';

  testWidgets('echoes text and counts with two real isolates', (tester) async {
    await tester.pumpWidget(
      const AppDependencies(child: App(locale: Locale('en'))),
    );
    await tester.pumpAndSettle();

    // Echo text.
    await tester.enterText(find.byKey(EchoTextKeys.input), 'Hello isolates');
    await tester.pump();
    await tester.tap(find.byKey(EchoTextKeys.submit));
    await tester.pumpAndSettle();
    expect(textOf(tester, EchoTextKeys.label), 'Hello isolates');

    // Isolate counter, driven by the real coordinator and worker isolates.
    await tester.tap(find.text('Isolates'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(IsolateCounterKeys.limitInput), '4');
    await tester.tap(find.byKey(IsolateCounterKeys.start));

    final seen = <String>[];
    const step = Duration(milliseconds: 50);
    for (var i = 0; i < 200; i++) {
      await tester.pump(step);
      final value = textOf(tester, IsolateCounterKeys.value);
      if (seen.isEmpty || seen.last != value) {
        seen.add(value);
      }
      if (textOf(tester, IsolateCounterKeys.status) == 'Finished') {
        break;
      }
    }

    expect(textOf(tester, IsolateCounterKeys.status), 'Finished');
    expect(textOf(tester, IsolateCounterKeys.value), '4');
    expect(seen.where((value) => int.tryParse(value) != null), [
      '1',
      '2',
      '3',
      '4',
    ]);
  });
}
