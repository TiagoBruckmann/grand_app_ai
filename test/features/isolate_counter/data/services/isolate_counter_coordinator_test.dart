@Timeout(Duration(seconds: 30))
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/core/result/result.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/isolate_counter_coordinator.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';

// These tests drive real worker isolates with a near-zero interval.
void main() {
  const timeout = Duration(seconds: 10);
  late IsolateCounterCoordinator coordinator;

  List<CounterEmission> sequence(int from, int to) => [
    for (var value = from; value <= to; value++)
      CounterEmission(
        value: value,
        parity: value.isOdd ? ParityEnum.odd : ParityEnum.even,
      ),
  ];

  setUp(() {
    coordinator = IsolateCounterCoordinator(interval: Duration.zero);
  });

  tearDown(() => coordinator.dispose());

  test('emits 1..N in order with alternating parity', () async {
    final emissions = coordinator.emissions.take(20).toList();

    final result = await coordinator.start(limit: 20);

    expect(result, isA<Ok<void>>());
    expect(await emissions.timeout(timeout), sequence(1, 20));
  });

  test('stops emitting once the limit is reached', () async {
    final received = <CounterEmission>[];
    final subscription = coordinator.emissions.listen(received.add);
    addTearDown(subscription.cancel);

    await coordinator.start(limit: 5);
    await coordinator.emissions
        .firstWhere((emission) => emission.value == 5)
        .timeout(timeout);
    // Give a hypothetical sixth turn the chance to show up.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(received, sequence(1, 5));
  });

  test('pause holds the sequence and resume continues it', () async {
    coordinator.interval = const Duration(milliseconds: 20);
    final received = <CounterEmission>[];
    final subscription = coordinator.emissions.listen(received.add);
    addTearDown(subscription.cancel);

    await coordinator.start(limit: 10);
    await coordinator.emissions
        .firstWhere((emission) => emission.value == 3)
        .timeout(timeout);
    coordinator.pause();
    final countWhenPaused = received.length;
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(received.length, countWhenPaused);

    coordinator.resume();
    await coordinator.emissions
        .firstWhere((emission) => emission.value == 10)
        .timeout(timeout);

    expect(received, sequence(1, 10));
  });

  test('a new start after stop begins again at 1', () async {
    await coordinator.start(limit: 100);
    await coordinator.emissions
        .firstWhere((emission) => emission.value == 4)
        .timeout(timeout);
    await coordinator.stop();

    final emissions = coordinator.emissions.take(3).toList();
    await coordinator.start(limit: 3);

    expect(await emissions.timeout(timeout), sequence(1, 3));
  });

  test('rapid start, stop, start never leaks values of an old run', () async {
    final received = <CounterEmission>[];
    final subscription = coordinator.emissions.listen(received.add);
    addTearDown(subscription.cancel);

    final first = coordinator.start(limit: 1000);
    await coordinator.stop();
    final second = coordinator.start(limit: 6);
    await Future.wait([first, second]);
    await coordinator.emissions
        .firstWhere((emission) => emission.value == 6)
        .timeout(timeout);

    expect(received, sequence(1, 6));
  });

  test('stop emits nothing afterwards', () async {
    await coordinator.start(limit: 1000);
    await coordinator.emissions.first.timeout(timeout);

    await coordinator.stop();
    final afterStop = <CounterEmission>[];
    final subscription = coordinator.emissions.listen(afterStop.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(afterStop, isEmpty);
  });

  test('dispose closes the emissions stream', () async {
    final done = Completer<void>();
    coordinator.emissions.listen(null, onDone: done.complete);
    await coordinator.start(limit: 1000);

    await coordinator.dispose();

    await expectLater(done.future.timeout(timeout), completes);
  });
}
