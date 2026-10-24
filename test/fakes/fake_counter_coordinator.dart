import 'dart:async';

import 'package:grand_app_ia_challange1/core/result/result.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_coordinator.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';

class FakeCounterCoordinator implements CounterCoordinator {
  final StreamController<CounterEmission> _emissions =
      StreamController<CounterEmission>.broadcast(sync: true);

  Result<void> startResult = const Result.ok(null);
  // When set, start() resolves only when the test completes it, simulating
  // a slow spawn.
  Completer<Result<void>>? startGate;
  Duration? lastInterval;
  int? lastLimit;
  int startCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;

  bool get hasListener => _emissions.hasListener;

  void emit(CounterEmission emission) => _emissions.add(emission);

  void emitError(Exception error) => _emissions.addError(error);

  @override
  Stream<CounterEmission> get emissions => _emissions.stream;

  @override
  set interval(Duration value) => lastInterval = value;

  @override
  Future<Result<void>> start({required int limit}) async {
    startCalls++;
    lastLimit = limit;
    if (startGate case final gate?) {
      return gate.future;
    }
    return startResult;
  }

  @override
  void pause() => pauseCalls++;

  @override
  void resume() => resumeCalls++;

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> dispose() => _emissions.close();
}
