import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/core/result/result.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_exception.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_status_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';

import '../../../../fakes/fake_counter_coordinator.dart';

void main() {
  late FakeCounterCoordinator coordinator;
  late IsolateCounterViewModel viewModel;

  const one = CounterEmission(value: 1, parity: ParityEnum.odd);
  const two = CounterEmission(value: 2, parity: ParityEnum.even);

  setUp(() {
    coordinator = FakeCounterCoordinator();
    viewModel = IsolateCounterViewModel(coordinator: coordinator);
  });

  tearDown(() async {
    viewModel.dispose();
    await coordinator.dispose();
  });

  group('initial state', () {
    test('is idle with defaults pushed to the coordinator', () {
      expect(viewModel.status, CounterStatusEnum.idle);
      expect(viewModel.current, isNull);
      expect(viewModel.limit, IsolateCounterViewModel.defaultLimit);
      expect(coordinator.lastInterval, IsolateCounterViewModel.defaultInterval);
    });

    test('allows start and limit editing only', () {
      expect(viewModel.canStart, isTrue);
      expect(viewModel.canEditLimit, isTrue);
      expect(viewModel.canTogglePause, isFalse);
      expect(viewModel.canStop, isFalse);
      expect(viewModel.canChangeInterval, isFalse);
    });
  });

  group('limit validation', () {
    for (final (input, expected) in [
      ('2', 2),
      ('1000', 1000),
      ('1', null),
      ('1001', null),
      ('', null),
      ('abc', null),
    ]) {
      test('"$input" parses to $expected', () {
        viewModel.onLimitChanged(input);

        expect(viewModel.limit, expected);
        expect(viewModel.canStart, expected != null);
      });
    }
  });

  group('start', () {
    test('moves to running and forwards the limit', () async {
      viewModel.onLimitChanged('6');

      await viewModel.start();

      expect(viewModel.status, CounterStatusEnum.running);
      expect(coordinator.lastLimit, 6);
      expect(viewModel.canEditLimit, isFalse);
      expect(viewModel.canChangeInterval, isTrue);
    });

    test('moves to failed when the coordinator returns an error', () async {
      const failure = CounterSpawnFailed(ParityEnum.odd, 'boom');
      coordinator.startResult = const Result.error(failure);

      await viewModel.start();

      expect(viewModel.status, CounterStatusEnum.failed);
      expect(viewModel.failure, failure);
    });

    test('disables pause until the workers are spawned', () async {
      final gate = coordinator.startGate = Completer<Result<void>>();

      final starting = viewModel.start();
      expect(viewModel.canTogglePause, isFalse);

      gate.complete(const Result.ok(null));
      await starting;
      expect(viewModel.canTogglePause, isTrue);
    });

    test('ignores a late spawn error after the user stopped', () async {
      final gate = coordinator.startGate = Completer<Result<void>>();
      final starting = viewModel.start();

      await viewModel.stop();
      gate.complete(
        const Result<void>.error(
          CounterSpawnFailed(ParityEnum.odd, 'too late'),
        ),
      );
      await starting;

      expect(viewModel.status, CounterStatusEnum.idle);
      expect(viewModel.failure, isNull);
    });

    test('is ignored while already running', () async {
      await viewModel.start();
      await viewModel.start();

      expect(coordinator.startCalls, 1);
    });
  });

  group('emissions', () {
    test('update the current value in order', () async {
      await viewModel.start();

      coordinator.emit(one);
      expect(viewModel.current, one);

      coordinator.emit(two);
      expect(viewModel.current, two);
    });

    test('reaching the limit finishes the run', () async {
      viewModel.onLimitChanged('2');
      await viewModel.start();

      coordinator
        ..emit(one)
        ..emit(two);

      expect(viewModel.status, CounterStatusEnum.finished);
      expect(viewModel.canStart, isTrue);
    });

    test('are ignored when idle', () {
      coordinator.emit(one);

      expect(viewModel.current, isNull);
    });

    test('a stream error marks the run as failed', () async {
      await viewModel.start();

      coordinator.emitError(
        const CounterWorkerCrashed(ParityEnum.even, 'boom'),
      );

      expect(viewModel.status, CounterStatusEnum.failed);
      expect(viewModel.failure, isA<CounterWorkerCrashed>());
    });
  });

  group('pause and stop', () {
    test('togglePause pauses and resumes the coordinator', () async {
      await viewModel.start();

      viewModel.togglePause();
      expect(viewModel.status, CounterStatusEnum.paused);
      expect(coordinator.pauseCalls, 1);

      viewModel.togglePause();
      expect(viewModel.status, CounterStatusEnum.running);
      expect(coordinator.resumeCalls, 1);
    });

    test('togglePause does nothing when idle', () {
      viewModel.togglePause();

      expect(viewModel.status, CounterStatusEnum.idle);
      expect(coordinator.pauseCalls, 0);
    });

    test('stop resets to idle and clears the value', () async {
      await viewModel.start();
      coordinator.emit(one);

      await viewModel.stop();

      expect(viewModel.status, CounterStatusEnum.idle);
      expect(viewModel.current, isNull);
      expect(coordinator.stopCalls, 1);
    });
  });

  group('interval', () {
    test('is clamped and forwarded to the coordinator', () {
      viewModel.setInterval(const Duration(milliseconds: 50));
      expect(viewModel.interval, IsolateCounterViewModel.minInterval);

      viewModel.setInterval(const Duration(milliseconds: 800));
      expect(coordinator.lastInterval, const Duration(milliseconds: 800));
    });

    test('does not notify when unchanged', () {
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.setInterval(IsolateCounterViewModel.defaultInterval);

      expect(notifications, 0);
    });
  });

  test('dispose cancels the subscription and stops the run', () async {
    final ownCoordinator = FakeCounterCoordinator();
    addTearDown(ownCoordinator.dispose);
    final disposable = IsolateCounterViewModel(coordinator: ownCoordinator);
    await disposable.start();

    disposable.dispose();

    expect(ownCoordinator.hasListener, isFalse);
    expect(ownCoordinator.stopCalls, 1);
  });
}
