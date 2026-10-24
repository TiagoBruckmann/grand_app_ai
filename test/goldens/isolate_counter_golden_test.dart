@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_screen.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_counter_coordinator.dart';
import '../helpers/pump_app.dart';
import 'golden_helpers.dart';

void main() {
  late FakeCounterCoordinator coordinator;

  setUp(() => coordinator = FakeCounterCoordinator());

  tearDown(() => coordinator.dispose());

  Future<void> start(WidgetTester tester) async {
    await tester.tap(find.byKey(IsolateCounterKeys.start));
    await tester.pump();
  }

  Future<void> emit(WidgetTester tester, int value) async {
    coordinator.emit(
      CounterEmission(
        value: value,
        parity: value.isOdd ? ParityEnum.odd : ParityEnum.even,
      ),
    );
    await tester.pump();
  }

  final states = <String, Future<void> Function(WidgetTester tester)?>{
    'idle': null,
    'running_odd': (tester) async {
      await start(tester);
      await emit(tester, 7);
    },
    'running_even': (tester) async {
      await start(tester);
      await emit(tester, 8);
    },
    'paused': (tester) async {
      await start(tester);
      await emit(tester, 5);
      await tester.tap(find.byKey(IsolateCounterKeys.togglePause));
    },
    'finished': (tester) async {
      await start(tester);
      await emit(tester, IsolateCounterViewModel.defaultLimit);
    },
  };

  for (final themeMode in goldenThemes) {
    for (final MapEntry(key: state, value: arrange) in states.entries) {
      testWidgets('isolate counter $state (${themeMode.name})', (tester) async {
        await expectScreenGolden(
          tester,
          name: 'isolate_counter_$state',
          screen: ChangeNotifierProvider(
            create: (_) => IsolateCounterViewModel(coordinator: coordinator),
            child: const IsolateCounterScreen(),
          ),
          themeMode: themeMode,
          arrange: arrange,
        );
      }, variant: mobilePlatforms);
    }
  }
}
