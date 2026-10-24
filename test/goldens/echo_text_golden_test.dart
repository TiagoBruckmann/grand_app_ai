@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/view_model/echo_text_view_model.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_keys.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/pump_app.dart';
import 'golden_helpers.dart';

void main() {
  final screen = ChangeNotifierProvider(
    create: (_) => EchoTextViewModel(),
    child: const EchoTextScreen(),
  );

  for (final themeMode in goldenThemes) {
    testWidgets('echo text initial (${themeMode.name})', (tester) async {
      await expectScreenGolden(
        tester,
        name: 'echo_text_initial',
        screen: screen,
        themeMode: themeMode,
      );
    }, variant: mobilePlatforms);

    testWidgets('echo text filled (${themeMode.name})', (tester) async {
      await expectScreenGolden(
        tester,
        name: 'echo_text_filled',
        screen: screen,
        themeMode: themeMode,
        arrange: (tester) async {
          await tester.enterText(find.byKey(EchoTextKeys.input), 'Hello');
          await tester.pump();
          await tester.tap(find.byKey(EchoTextKeys.submit));
        },
      );
    }, variant: mobilePlatforms);
  }
}
