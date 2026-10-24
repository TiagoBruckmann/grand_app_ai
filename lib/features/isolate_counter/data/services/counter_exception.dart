import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';

sealed class CounterException implements Exception {
  const CounterException();
}

final class CounterSpawnFailed extends CounterException {
  const CounterSpawnFailed(this.parity, this.cause);

  final ParityEnum parity;
  final Object cause;

  @override
  String toString() => 'CounterSpawnFailed(${parity.name}): $cause';
}

final class CounterWorkerCrashed extends CounterException {
  const CounterWorkerCrashed(this.parity, this.message);

  final ParityEnum parity;
  final String message;

  @override
  String toString() => 'CounterWorkerCrashed(${parity.name}): $message';
}
