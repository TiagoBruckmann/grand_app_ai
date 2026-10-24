# Spec — Isolate counter (multithreading task)

> Implement two threads: one that counts odd numbers and another that counts
> even numbers. The threads should take turns updating a label so that the
> numbers appear in sequence (1, 2, 3, 4, etc.) in a synchronized manner.

## Why isolates

Dart has no shared-memory threads. `Future`, `async`/`await` and `Timer` run on
the **same** event loop (one thread). Isolates are Dart's real units of
parallel execution, each with its own memory and event loop, communicating only
through messages. Two long-lived isolates spawned with `Isolate.spawn` are the
faithful implementation of "two threads". `compute`/`Isolate.run` are one-shot
and are **not** used here.

## Architecture

```
            ┌──────────── main isolate ─────────────┐
            │ IsolateCounterViewModel (ChangeNotifier)
            │        ▲ Stream<CounterEmission>       │
            │ CounterCoordinator (service)           │
            │   - owns turn token, interval, limit   │
            └──────┬─────────────────────▲───────────┘
     NextTurn(run) │                     │ Emitted(run, value, parity)
            ┌──────▼──────┐       ┌──────┴──────┐
            │ odd worker  │       │ even worker │
            │ 1, 3, 5 …   │       │ 2, 4, 6 …   │
            └─────────────┘       └─────────────┘
```

**Token passing**: the coordinator holds the turn. It sends `NextTurn` to the
odd worker, which increments its own counter and replies `Emitted(1)`. The
coordinator publishes it, waits `interval`, then sends `NextTurn` to the even
worker, which replies `Emitted(2)`, and so on. Only one worker holds the token
at any time, so ordering is guaranteed by construction, not by timing.

## Files

```
features/isolate_counter/
├── domain/models/
│   ├── parity.dart              # enum ParityEnum { odd, even }
│   ├── counter_emission.dart    # value + parity (immutable)
│   └── counter_status.dart      # enum: idle, running, paused, finished, failed
├── data/services/
│   ├── worker_messages.dart     # sealed WorkerCommand / WorkerEvent
│   ├── parity_worker.dart       # top-level entry point `parityWorkerMain`
│   └── counter_coordinator.dart # spawn, handshake, turn loop, lifecycle
└── ui/
    ├── view_model/isolate_counter_view_model.dart
    └── widgets/…
```

### Messages (sealed, immutable)

- Main → worker: `NextTurn(int runId)`, `ShutdownWorker()`
- Worker → main: `WorkerReady(SendPort commands)`,
  `Emitted(int runId, int value, ParityEnum parity)`

### Worker (`parityWorkerMain(WorkerConfig config)`)

`WorkerConfig(SendPort events, ParityEnum parity)`. Starts at 1 (odd) or 2 (even),
steps by 2, keeps the counter **inside the isolate**. Replies to each
`NextTurn` with `Emitted` carrying the same `runId`. Exits on
`ShutdownWorker`.

### Coordinator (`CounterCoordinator`)

- `Stream<CounterEmission> get emissions`
- `Future<Result<void>> start({required int limit})`
- `void pause()` / `void resume()`
- `Future<void> stop()` — kills isolates, closes ports, resets counters
- `set interval(Duration value)` — read before scheduling each turn, so the
  slider takes effect on the next tick
- `Future<void> dispose()`
- Spawns workers with `debugName: 'odd-worker'` / `'even-worker'`,
  `onError` and `onExit` ports; a crash ends the run as `Result.error` /
  status `failed`.
- Increments `runId` on every start; drops any `Emitted` whose `runId` is not
  current (no stale values after stop → start).
- `pause()` cancels the pending turn timer; `resume()` re-sends `NextTurn` to
  the worker that owns the next turn.
- Reaching `limit` → status `finished`, workers shut down.
- Defined as an interface (`abstract interface class CounterCoordinator`) +
  `IsolateCounterCoordinator` implementation, so the ViewModel can be tested
  with a fake.

## UI

- Big label with the current number, `Semantics(liveRegion: true)`.
- Origin indicator: chip/badge "Odd isolate" / "Even isolate" with a distinct
  `colorScheme` color **and** icon/text (not color alone).
- Controls: Start, Pause/Resume (single toggle), Stop/Reset.
- Interval slider (`Slider.adaptive`), 100 ms – 2000 ms, default 500 ms,
  enabled while running.
- Limit N input (default 20, range 2–1000), editable only when idle.
- Status text (idle / running / paused / finished / failed), translated.

## Acceptance

1. Start → label shows 1, 2, 3, … N in order, parity alternating odd/even.
2. Pause → numbers stop; resume → continues from the next number.
3. Stop/Reset → label back to placeholder; a new start begins at 1.
4. Changing the slider changes the pace from the next tick.
5. Leaving the screen/app disposal kills both isolates (no leaks).
6. Rapid start/stop/start never shows a number from an old run.

## Tests

- Coordinator (real isolates, interval 0–5 ms): exact sequence 1..N, parity
  alternation, pause/resume, stop/restart from 1, stale `runId` ignored,
  limit reached → finished, dispose closes everything.
- ViewModel (fake coordinator): status transitions, button enablement, limit
  validation, dispose cancels subscription.
- Widget (Android + iOS): controls enabled/disabled per status, label and
  parity indicator update from fake emissions.
- Golden: idle, running (odd), running (even), paused, finished — light/dark ×
  Android/iOS.
- Integration: start with small N, wait until finished, assert last value N.
