import 'package:grand_app_ia_challange1/core/result/result.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';

abstract interface class CounterCoordinator {
  // Broadcast stream of every published number. A worker crash during a run
  // is delivered as a `CounterWorkerCrashed` error event.
  Stream<CounterEmission> get emissions;

  // Read before scheduling each turn, so a change applies from the next tick.
  set interval(Duration value);

  Future<Result<void>> start({required int limit});

  void pause();

  void resume();

  Future<void> stop();

  Future<void> dispose();
}
