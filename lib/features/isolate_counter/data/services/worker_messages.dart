import 'dart:isolate';

import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';

final class WorkerConfig {
  const WorkerConfig({required this.events, required this.parity});

  final SendPort events;
  final ParityEnum parity;
}

// Main isolate → worker.
sealed class WorkerCommand {
  const WorkerCommand();
}

final class NextTurn extends WorkerCommand {
  const NextTurn(this.runId);

  final int runId;
}

final class ShutdownWorker extends WorkerCommand {
  const ShutdownWorker();
}

// Worker → main isolate.
sealed class WorkerEvent {
  const WorkerEvent();
}

final class WorkerReady extends WorkerEvent {
  const WorkerReady(this.commands);

  final SendPort commands;
}

final class Emitted extends WorkerEvent {
  const Emitted({
    required this.runId,
    required this.value,
    required this.parity,
  });

  final int runId;
  final int value;
  final ParityEnum parity;
}
