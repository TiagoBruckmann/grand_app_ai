import 'dart:isolate';

import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/worker_messages.dart';

// Entry point of a worker isolate. It must stay top-level so that
// `Isolate.spawn` can send it to the new isolate.
void parityWorkerMain(WorkerConfig config) {
  // The counter lives only here: the main isolate never computes numbers,
  // it just hands the turn to whichever worker owns it.
  var next = config.parity.firstValue;
  final commands = RawReceivePort(null, '${config.parity.name}-commands');

  commands.handler = (Object? message) {
    if (message is! WorkerCommand) {
      return;
    }
    switch (message) {
      case NextTurn(:final runId):
        config.events.send(
          Emitted(runId: runId, value: next, parity: config.parity),
        );
        next += 2;
      case ShutdownWorker():
        commands.close();
    }
  };

  config.events.send(WorkerReady(commands.sendPort));
}
