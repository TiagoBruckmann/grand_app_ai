import 'dart:async';
import 'dart:isolate';

import 'package:grand_app_ia_challange1/core/result/result.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_coordinator.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_exception.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/parity_worker.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/worker_messages.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';

// Token passing: only one worker holds the turn at any time, so the order
// 1, 2, 3… is guaranteed by construction rather than by timing.
final class IsolateCounterCoordinator implements CounterCoordinator {
  IsolateCounterCoordinator({
    this._interval = const Duration(milliseconds: 500),
    this._handshakeTimeout = const Duration(seconds: 5),
  });

  final Duration _handshakeTimeout;
  // Synchronous so an emission is delivered before stop() returns, never
  // queued behind it where it could leak into the next run. Every `add`
  // comes from a port handler, never from inside a listener.
  final StreamController<CounterEmission> _emissions =
      StreamController<CounterEmission>.broadcast(sync: true);

  Duration _interval;
  int _runId = 0;
  _Run? _run;
  CounterWorkerCrashed? _spawnCrash;
  bool _disposed = false;

  @override
  Stream<CounterEmission> get emissions => _emissions.stream;

  @override
  set interval(Duration value) => _interval = value;

  @override
  Future<Result<void>> start({required int limit}) async {
    if (_disposed) {
      throw StateError('start() called on a disposed coordinator');
    }
    if (limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'must be at least 1');
    }
    await stop();
    final runId = ++_runId;
    _spawnCrash = null;

    _Worker? odd;
    _Worker? even;
    try {
      odd = await _spawn(runId, ParityEnum.odd);
      even = await _spawn(runId, ParityEnum.even);
    } on CounterSpawnFailed catch (error) {
      odd?.shutdown();
      return Result.error(error);
    }

    if (_disposed || runId != _runId) {
      odd.shutdown();
      even.shutdown();
      return const Result.ok(null);
    }
    if (_spawnCrash case final crash?) {
      odd.shutdown();
      even.shutdown();
      return Result.error(crash);
    }

    final run = _Run(id: runId, limit: limit, odd: odd, even: even);
    _run = run;
    _sendTurn(run);
    return const Result.ok(null);
  }

  @override
  void pause() {
    final run = _run;
    if (run == null || run.paused) {
      return;
    }

    run.paused = true;
    run.timer?.cancel();
    run.timer = null;
  }

  @override
  void resume() {
    final run = _run;
    if (run == null || !run.paused) {
      return;
    }

    run.paused = false;
    if (!run.inFlight) {
      _sendTurn(run);
    }
  }

  @override
  Future<void> stop() async {
    _runId++;
    _teardown();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;
    await stop();
    await _emissions.close();
  }

  Future<_Worker> _spawn(int runId, ParityEnum parity) => _Worker.spawn(
    parity: parity,
    handshakeTimeout: _handshakeTimeout,
    onEmitted: _onEmitted,
    onCrash: (message) => _onCrash(runId, parity, message),
  );

  void _sendTurn(_Run run) {
    if (!identical(_run, run) || run.paused) {
      return;
    }

    run.timer = null;
    run.inFlight = true;
    run.owner.send(NextTurn(run.id));
  }

  void _onEmitted(Emitted event) {
    final run = _run;
    if (run == null || event.runId != run.id) {
      return;
    }

    run.inFlight = false;
    _emissions.add(CounterEmission(value: event.value, parity: event.parity));

    if (event.value >= run.limit) {
      return _teardown();
    }

    run.nextTurn = event.parity.opposite;
    if (!run.paused) {
      run.timer = Timer(_interval, () => _sendTurn(run));
    }
  }

  void _onCrash(int runId, ParityEnum parity, String message) {
    // Expected exits never get here: teardown closes the ports first.
    if (runId != _runId) {
      return;
    }

    final crash = CounterWorkerCrashed(parity, message);
    if (_run == null) {
      // Still spawning the other worker; start() reports it.
      _spawnCrash = crash;
      return;
    }

    _teardown();
    _emissions.addError(crash);
  }

  void _teardown() {
    final run = _run;
    _run = null;
    if (run == null) {
      return;
    }

    run.timer?.cancel();
    run.odd.shutdown();
    run.even.shutdown();
  }
}

final class _Run {
  _Run({
    required this.id,
    required this.limit,
    required this.odd,
    required this.even,
  });

  final int id;
  final int limit;
  final _Worker odd;
  final _Worker even;

  ParityEnum nextTurn = ParityEnum.odd;
  bool inFlight = false;
  bool paused = false;
  Timer? timer;

  _Worker get owner => switch (nextTurn) {
    ParityEnum.odd => odd,
    ParityEnum.even => even,
  };
}

final class _Worker {
  _Worker._({
    required this._isolate,
    required this._commands,
    required this._ports,
  });

  final Isolate _isolate;
  final SendPort _commands;
  final List<RawReceivePort> _ports;

  static Future<_Worker> spawn({
    required ParityEnum parity,
    required Duration handshakeTimeout,
    required void Function(Emitted event) onEmitted,
    required void Function(String message) onCrash,
  }) async {
    final ready = Completer<SendPort>();
    final events = RawReceivePort(null, '${parity.name}-events');
    final errors = RawReceivePort(null, '${parity.name}-errors');
    final exits = RawReceivePort(null, '${parity.name}-exits');
    final ports = [events, errors, exits];

    events.handler = (Object? message) {
      if (message is! WorkerEvent) {
        return;
      }

      switch (message) {
        case WorkerReady(:final commands):
          if (!ready.isCompleted) {
            ready.complete(commands);
          }
        case Emitted():
          onEmitted(message);
      }
    };

    void fail(String message) {
      // Dying before the handshake fails the spawn right away instead of
      // waiting for the handshake timeout.
      if (ready.isCompleted) {
        return onCrash(message);
      }

      ready.completeError(CounterWorkerCrashed(parity, message));
    }

    errors.handler = (Object? message) => fail(switch (message) {
      [final Object? error, _] => '$error',
      _ => '$message',
    });
    exits.handler = (Object? _) => fail('${parity.name} worker exited');

    final Isolate isolate;
    try {
      isolate = await Isolate.spawn(
        parityWorkerMain,
        WorkerConfig(events: events.sendPort, parity: parity),
        debugName: '${parity.name}-worker',
        onError: errors.sendPort,
        onExit: exits.sendPort,
      );
    } on IsolateSpawnException catch (error) {
      _closeAll(ports);
      throw CounterSpawnFailed(parity, error);
    } catch (_) {
      _closeAll(ports);
      rethrow;
    }

    try {
      final commands = await ready.future.timeout(handshakeTimeout);
      return _Worker._(isolate: isolate, commands: commands, ports: ports);
    } on Exception catch (error) {
      isolate.kill(priority: Isolate.immediate);
      _closeAll(ports);
      throw CounterSpawnFailed(parity, error);
    }
  }

  void send(WorkerCommand command) => _commands.send(command);

  void shutdown() {
    _closeAll(_ports);
    _commands.send(const ShutdownWorker());
    _isolate.kill();
  }

  static void _closeAll(List<RawReceivePort> ports) {
    for (final port in ports) {
      port.close();
    }
  }
}
